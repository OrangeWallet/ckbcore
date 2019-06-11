import 'dart:math';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_status.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckb_sdk/ckb_system_contract/ckb_system_contract.dart';
import 'package:ckb_sdk/ckb_system_contract/system_contract.dart';
import 'package:ckbcore/base/bean/balance_bean.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/bean/receiver_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/credential.dart';
import 'package:ckbcore/base/core/keystore.dart';
import 'package:ckbcore/base/core/my_wallet.dart';
import 'package:ckbcore/base/interface/sync_interface.dart';
import 'package:ckbcore/base/interface/transaction_interface.dart';
import 'package:ckbcore/base/interface/wallet_core_interface.dart';
import 'package:ckbcore/base/store/store_manager.dart';
import 'package:ckbcore/base/sync/sync_service.dart';
import 'package:ckbcore/base/transction/transaction_manager.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells.dart';
import 'package:ckbcore/base/utils/get_cells_utils/update_unspent_cells.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/base/utils/random_privatekey.dart';
import 'package:convert/convert.dart';

abstract class WalletCore implements SyncInterface, WalletCoreInterface, TransactionInterface {
  static bool isDebug = true;

  SyncService _syncService;
  CellsResultBean _cellsResultBean = CellsResultBean([], '-1');
  StoreManager _storeManager;
  BalanceBean _balanceBean;
  CKBApiClient _apiClient;
  Network _network;
  MyWallet _myWallet;

  WalletCore(String storePath, String nodeUrl, Network network, bool _isDebug) {
    Constant.NodeUrl = nodeUrl;
    _apiClient = CKBApiClient(Constant.NodeUrl);
    isDebug = _isDebug;
    _storeManager = StoreManager(storePath);
    _network = network;
  }

  @override
  MyWallet get myWallet => _myWallet;

  @override
  CellsResultBean get cellsResultBean => _cellsResultBean;

  BalanceBean get balanceBean => _balanceBean;

  @override
  CKBApiClient get apiClient => _apiClient;

  @override
  Network get network => _network;

  Future walletFromStore(String password) async {
    String json = await readWallet(password);
    var keystore = Keystore.fromJson(json, password);
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(keystore.privateKey).publicKey);
    _cellsResultBean = await _storeManager.getSyncedCells();
    await _getSystemContract();
    return;
  }

  Future createWallet(String password) async {
    var privateKey = createRandonPrivateKey();
    var keystore = Keystore.createNew(privateKey, password, Random.secure());
    await writeWallet(keystore.toJson(), password);
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(keystore.privateKey).publicKey);
    _cellsResultBean = await _storeManager.getSyncedCells();
    _syncService = SyncService(_myWallet, this, _apiClient);
    _cellsResultBean.syncedBlockNumber = '-1';
    await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    await _getSystemContract();
    return;
  }

  Future importFromKeystore(String json, String password) async {
    var keystore = Keystore.fromJson(json, password);
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(keystore.privateKey).publicKey);
    _cellsResultBean = await _storeManager.getSyncedCells();
    await _getSystemContract();
    return;
  }

  Future importFromPrivateKey(String privateKey, String password) async {
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(hex.decode(privateKey)).publicKey);
    var keystore = Keystore.createNew(hex.decode(privateKey), password, Random());
    await writeWallet(keystore.toJson(), password);
    _cellsResultBean = await _storeManager.getSyncedCells();
    await _getSystemContract();
    return;
  }

  Future _getSystemContract() async {
    SystemContract systemContract =
        await getSystemContract(CKBApiClient(Constant.NodeUrl), network);
    Constant.CodeHash = systemContract.codeHash;
  }

  updateCurrentIndexCells() async {
    try {
      _syncService = SyncService(_myWallet, this, _apiClient);
      await calculateBalance();
      if (_cellsResultBean.syncedBlockNumber == '') {
        Log.log('sync from genesis block');
        _cellsResultBean =
            await getCurrentIndexCells(_myWallet, 0, _apiClient, (double processing) {
          syncProcess(processing);
        });
        await _storeManager.syncCells(_cellsResultBean);
      } else if (_cellsResultBean.syncedBlockNumber == '-1') {
        String targetBlockNumber = await _apiClient.getTipBlockNumber();
        Log.log('sync from tip block $targetBlockNumber');
        _cellsResultBean.syncedBlockNumber = targetBlockNumber;
        await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
      } else {
        Log.log('sync from ${_cellsResultBean.syncedBlockNumber}');
        var updateCellsResult =
            await updateUnspentCells(_myWallet, _cellsResultBean, _apiClient, (double processing) {
          syncProcess(processing);
        });
        if (updateCellsResult.isChange) {
          _cellsResultBean = updateCellsResult.cellsResultBean;
          await _storeManager.syncCells(_cellsResultBean);
        } else {
          _cellsResultBean.syncedBlockNumber = updateCellsResult.cellsResultBean.syncedBlockNumber;
          await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
        }
      }
      await calculateBalance();
      syncProcess(1.0);
      _syncService.start();
    } catch (e) {
      syncException(e);
    }
  }

  Future stopSync() async {
    Future stop = Future(() => _syncService.stop(() => {}));
    await stop;
  }

  Future clearStore() async {
    _cellsResultBean = CellsResultBean([], '');
    _balanceBean = BalanceBean(0, 0);
    await _storeManager.clearAll();
  }

  Future sendCapacity(List<ReceiverBean> receivers, Network network, String password) async {
    TransactionManager transactionManager =
        TransactionManager(this, hex.decode(await readWallet(password)));
    String hash = await transactionManager.sendCapacity(receivers);
    Log.log(hash);
    return hash;
  }

  @override
  Future thinBlockUpdate(
      bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock) async {
    if (isCellsChange) {
      _cellsResultBean = cellsResult;
      await _storeManager.syncCells(_cellsResultBean);
      await calculateBalance();
    } else {
      _cellsResultBean.syncedBlockNumber = thinBlock.thinHeader.number;
      await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    }
    await blockChanged(thinBlock);
  }

  Future calculateBalance() async {
    int total = 0;
    int available = 0;
    _cellsResultBean.cells.forEach((cell) {
      if (CellWithStatus.LIVE == cell.status) {
        total += int.parse(cell.cellOutput.capacity);
        if (cell.cellOutput.data == '0') {
          available += int.parse(cell.cellOutput.capacity);
        }
      }
    });
    _balanceBean = BalanceBean(total, available);
    cellsChanged(_balanceBean);
  }
}
