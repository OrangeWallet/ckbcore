import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/core/sync_service.dart';
import 'package:ckbcore/src/base/store/store_manager.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart' as GetCellsUtils;
import 'package:ckbcore/src/base/utils/searchCells/update_unspent_cells.dart' as UpdateCellsUtils;

class WalletCore {
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

  startSync() {
    _syncService.start();
  }

  //Using this when opening app.
  Future updateCurrentIndexCells() async {
    _cellsResultBean = await MyStoreManager.getSyncedCells();
    String targetBlockNumber = await CKBApiClient(nodeUrl: DefaultNodeUrl).getTipBlockNumber();
    var updateCellsResult =
        await UpdateCellsUtils.updateCurrentIndexCells(_hdCore, _cellsResultBean, int.parse(targetBlockNumber));
    if (updateCellsResult.isChange) {
      _cellsResultBean = updateCellsResult.cellsResultBean;
      await MyStoreManager.syncCells(_cellsResultBean);
    }
    startSync();
    return;
  }

  // Using this after import wallet.
  Future getCurrentIndexCells() async {
    String targetBlockNumber = await CKBApiClient(nodeUrl: DefaultNodeUrl).getTipBlockNumber();
    var cells = await GetCellsUtils.getCurrentIndexCells(_hdCore, 0, int.parse(targetBlockNumber));
    _cellsResultBean = CellsResultBean(cells, targetBlockNumber);
    await MyStoreManager.syncCells(_cellsResultBean);
    startSync();
    return;
  }

  //Searching all cells.Include index before current receive index and change index
  Future getWholeHDUnspentCells() async {
    String targetBlockNumber = await CKBApiClient(nodeUrl: DefaultNodeUrl).getTipBlockNumber();
    var cells = await GetCellsUtils.getWholeHDAllCells(_hdCore, int.parse(targetBlockNumber));
    _cellsResultBean = CellsResultBean(cells, targetBlockNumber);
    await MyStoreManager.syncCells(_cellsResultBean);
    return;
  }
}
