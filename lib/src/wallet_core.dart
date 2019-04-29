import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/core/sync_service.dart';
import 'package:ckbcore/src/base/store/store_manager.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart';

class WalletCore with GetUnspentCellsUtils {
  static StoreManager MyStoreManager;
  static int IntervalBlockNumber = 100;
  static int IntervalSyncTime = 60;
  static String DefaultNodeUrl = 'http://47.111.175.189:8121';

  final HDCoreConfig _hdCoreConfig;

  HDCore _hdCore;
  SyncService _syncService;
  CellsResultBean _cellsResultBean;

  WalletCore(this._hdCoreConfig, String storePath, {String nodeUrl}) {
    _hdCore = HDCore(_hdCoreConfig);
    DefaultNodeUrl = nodeUrl == null ? DefaultNodeUrl : nodeUrl;
    MyStoreManager = StoreManager(storePath);
    _syncService = SyncService();
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  CellsResultBean get cellsResultBean => _cellsResultBean;

  startSync() async {
    _syncService.start();
  }

  Future<CellsResultBean> updateCurrentIndexCells() async {}

  Future getCurrentIndexCells() async {
    String targetBlockNumber = await CKBApiClient(nodeUrl: DefaultNodeUrl).getTipBlockNumber();
    var cells = await getCurrentIndex(_hdCore, int.parse(targetBlockNumber));
    _cellsResultBean = CellsResultBean(cells, targetBlockNumber);
    await MyStoreManager.syncCells(_cellsResultBean);
    return;
  }

  //Searching all cells.Include index before current receive index and change index
  Future getWholeHDUnspentCells() async {
    String targetBlockNumber = await CKBApiClient(nodeUrl: DefaultNodeUrl).getTipBlockNumber();
    var cells = await getWholeHD(_hdCore, int.parse(targetBlockNumber));
    _cellsResultBean = CellsResultBean(cells, targetBlockNumber);
    await MyStoreManager.syncCells(_cellsResultBean);
    return;
  }
}
