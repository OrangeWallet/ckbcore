import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/base/bean/balance_bean.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/bean/receiver_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/constant/constant.dart' show ApiClient, NodeUrl;
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/core/hd_index_wallet.dart';
import 'package:ckbcore/base/exception/exception.dart';
import 'package:ckbcore/base/interface/sync_interface.dart';
import 'package:ckbcore/base/interface/transaction_interface.dart';
import 'package:ckbcore/base/interface/wallet_core_interface.dart';
import 'package:ckbcore/base/store/store_manager.dart';
import 'package:ckbcore/base/sync/sync_service.dart';
import 'package:ckbcore/base/transction/transaction_manager.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells.dart';
import 'package:ckbcore/base/utils/get_cells_utils/update_unspent_cells.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/base/utils/mnemonic_to_seed.dart';
import 'package:convert/convert.dart';

abstract class WalletCore implements SyncInterface, WalletCoreInterface, TransactionInterface {
  static bool isDebug = true;

  HDCore _hdCore;
  SyncService _syncService;
  CellsResultBean _cellsResultBean = CellsResultBean([], '-1');
  HDCoreConfig _hdCoreConfig;
  StoreManager _storeManager;
  BalanceBean _balanceBean;
  TransactionManager _transactionManager;

  WalletCore(String storePath, String nodeUrl, bool _isDebug) {
    if (nodeUrl != null) {
      NodeUrl = nodeUrl;
      ApiClient = CKBApiClient(NodeUrl);
    }
    isDebug = _isDebug;
    _storeManager = StoreManager(storePath);
    _transactionManager = TransactionManager(this);
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  CellsResultBean get cellsResultBean => _cellsResultBean;

  HDCoreConfig get hdCoreConfig => _hdCoreConfig;

  BalanceBean get balanceBean => _balanceBean;

  //Init HD Wallet from store
  Future init(String password) async {
    _hdCoreConfig = HDCoreConfig.fromJson(jsonDecode(await readWallet(password)));
    if (_hdCoreConfig.seed == '') {
      throw Exception('Seed is Empty');
    }
    _hdCore = HDCore(_hdCoreConfig);
    updateCurrentIndexCells();
    return;
  }

  //Create new HD Wallet
  Future create(String password) async {
    final mnemonic = bip39.generateMnemonic();
    Uint8List seed = await mnemonicToSeed(mnemonic);
    createStep(1);
    String seedStr = hex.encode(seed);
    _hdCoreConfig = HDCoreConfig(mnemonic, seedStr, 0, 0);
    _hdCore = HDCore(_hdCoreConfig);
    createStep(2);
    await writeWallet(jsonEncode(_hdCoreConfig), password);
    createStep(3);
    _syncService = SyncService(_hdCore, this);
    _cellsResultBean = await _storeManager.getSyncedCells();
    _cellsResultBean.syncedBlockNumber = '-1';
    await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    updateCurrentIndexCells();
    return;
  }

  //Import HD Wallet
  Future import(String mnemonic, String password) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Wrong mnemonic');
    }
    Uint8List seed = await mnemonicToSeed(mnemonic);
    createStep(1);
    String seedStr = hex.encode(seed);
    _hdCoreConfig = HDCoreConfig(mnemonic, seedStr, 0, 0);
    _hdCore = HDCore(_hdCoreConfig);
    createStep(2);
    await writeWallet(jsonEncode(_hdCoreConfig), password);
    createStep(3);
    updateCurrentIndexCells();
    return;
  }

  updateCurrentIndexCells() async {
    _syncService = SyncService(_hdCore, this);
    _cellsResultBean = await _storeManager.getSyncedCells();
    await calculateBalance();
    if (_cellsResultBean.syncedBlockNumber == '') {
      Log.log('sync from genesis block');
      _cellsResultBean = await getCurrentIndexCells(_hdCore, 0, (double processing) {
        syncProcess(processing);
      });
      await _storeManager.syncCells(_cellsResultBean);
    } else if (_cellsResultBean.syncedBlockNumber == '-1') {
      String targetBlockNumber = await ApiClient.getTipBlockNumber();
      Log.log('sync from tip block $targetBlockNumber');
      _cellsResultBean.syncedBlockNumber = targetBlockNumber;
      await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    } else {
      Log.log('sync from ${_cellsResultBean.syncedBlockNumber}');
      var updateCellsResult =
          await updateUnspentCells(_hdCore, _cellsResultBean, (double processing) {
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
  }

  Future stopSync() async {
    Future stop = Future(() => _syncService.stop(() => {}));
    await stop;
  }

  Future clearStore() async {
    _cellsResultBean = CellsResultBean([], '-1');
    _balanceBean = BalanceBean(0, 0);
    await _storeManager.clearAll();
  }

  Future sendToken(List<ReceiverBean> receivers, Network network) async {
    SendTransaction sendTransaction = await _transactionManager.generateTransaction(
        receivers, unusedReceiveWallet.getAddress(network), network);
    print(jsonEncode(sendTransaction));
    String hash = await ApiClient.sendTransaction(sendTransaction);
    print(hash);
  }

  @override
  Future thinBlockUpdate(
      bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock) async {
    if (isCellsChange) {
      _cellsResultBean = cellsResult;
      await _storeManager.syncCells(_cellsResultBean);
      await calculateBalance();
    } else {
      _cellsResultBean.syncedBlockNumber = cellsResult.syncedBlockNumber;
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

  @override
  CellsResultBean getCurrentCellsResult() {
    return _cellsResultBean;
  }
}
