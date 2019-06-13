import 'dart:math';

import 'package:ckb_sdk/ckb_address.dart';
import 'package:ckb_sdk/ckb_types.dart';
import 'package:ckbcore/src/bean/thin_block.dart';
import 'package:convert/convert.dart';

import 'bean/balance_bean.dart';
import 'bean/cells_result_bean.dart';
import 'bean/receiver_bean.dart';
import 'constant/constant.dart';
import 'core/credential.dart';
import 'core/keystore.dart';
import 'core/my_wallet.dart';
import 'interface/wallet_core_interface.dart';
import 'store/store_manager.dart';
import 'sync/sync_service.dart';
import 'transction/transaction_manager.dart' as TransactionManager;
import 'utils/log.dart';
import 'utils/random_privatekey.dart';

abstract class WalletCore implements WalletCoreInterface {
  static bool isDebug = true;

  SyncService _syncService;
  SyncInterface _syncInterface = SyncInterface();
  CellsResultBean _cellsResultBean = CellsResultBean([], '-1');
  StoreManager _storeManager;
  BalanceBean _balanceBean;
  CKBNetwork _network;
  MyWallet _myWallet;

  WalletCore(String storePath, String nodeUrl, CKBNetwork network, bool _isDebug) {
    Constant.NodeUrl = nodeUrl;
    isDebug = _isDebug;
    _storeManager = StoreManager(storePath);
    _network = network;
  }

  @override
  MyWallet get myWallet => _myWallet;

  @override
  CellsResultBean get cellsResultBean => _cellsResultBean;

  BalanceBean get balanceBean => _balanceBean;

  Future walletFromStore(String password) async {
    String json = await readWallet(password);
    var keystore = Keystore.fromJson(json, password);
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(keystore.privateKey).publicKey);
    _cellsResultBean = await _storeManager.getSyncedCells();
    return;
  }

  Future createWallet(String password) async {
    var privateKey = createRandonPrivateKey();
    var keystore = Keystore.createNew(privateKey, password, Random.secure());
    await writeWallet(keystore.toJson(), password);
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(keystore.privateKey).publicKey);
    _cellsResultBean = await _storeManager.getSyncedCells();
    _cellsResultBean.syncedBlockNumber = '-1';
    await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    return;
  }

  Future importFromKeystore(String json, String password) async {
    var keystore = Keystore.fromJson(json, password);
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(keystore.privateKey).publicKey);
    await writeWallet(keystore.toJson(), password);
    _cellsResultBean = await _storeManager.getSyncedCells();
    return;
  }

  Future importFromPrivateKey(String privateKey, String password) async {
    var keystore = Keystore.createNew(hex.decode(privateKey), password, Random());
    _myWallet = MyWallet(Credential.fromPrivateKeyBytes(hex.decode(privateKey)).publicKey);
    await writeWallet(keystore.toJson(), password);
    _cellsResultBean = await _storeManager.getSyncedCells();
    return;
  }

  startSync() {
    try {
      _syncInterface.lockScript = _myWallet.lockScript;
      _syncInterface.storeManager = _storeManager;
      _syncInterface.calculateBalance = () async => await calculateBalance();
      _syncInterface.setCellsBeanResult = (newCellsResult) => _cellsResultBean = newCellsResult;
      _syncInterface.getCellsBeanResult = () => _cellsResultBean;
      _syncInterface.syncException = (Exception e) => syncException(e);
      _syncInterface.syncProcess = (processing) => syncProcess(processing);
      _syncInterface.blockChanged = (ThinBlock thinBlock) => blockChanged(thinBlock);
      _syncService = SyncService(_syncInterface);
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

  Future sendCapacity(List<ReceiverBean> receivers, CKBNetwork network, String password) async {
    Keystore keystore = Keystore.fromJson(await readWallet(password), password);
    String hash = await TransactionManager.sendCapacity(
        keystore.privateKey, _cellsResultBean.cells, receivers, _network);
    Log.log(hash);
    return hash;
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
