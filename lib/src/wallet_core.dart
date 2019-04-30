import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/bean/thin_block.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/interface/sync_interface.dart';
import 'package:ckbcore/src/base/interface/wallet_core_interface.dart';
import 'package:ckbcore/src/base/store/store_manager.dart';
import 'package:ckbcore/src/base/sync/sync_service.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart' as GetCellsUtils;
import 'package:ckbcore/src/base/utils/searchCells/update_unspent_cells.dart' as UpdateCellsUtils;

class WalletCore implements SyncInterface {
  static StoreManager MyStoreManager;
  static int IntervalBlockNumber = 100;
  static int IntervalSyncTime = 20;
  static String DefaultNodeUrl = 'http://192.168.2.225:8114';

  final HDCoreConfig _hdCoreConfig;

  HDCore _hdCore;
  SyncService _syncService;
  CellsResultBean _cellsResultBean;
  WalletCoreInterface walletCoreInterface;

  WalletCore(this._hdCoreConfig, this.walletCoreInterface, String storePath, {String nodeUrl}) {
    _hdCore = HDCore(_hdCoreConfig);
    DefaultNodeUrl = nodeUrl == null ? DefaultNodeUrl : nodeUrl;
    MyStoreManager = StoreManager(storePath);
    _syncService = SyncService(_hdCore, this);
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  CellsResultBean get cellsResultBean => _cellsResultBean;

  startSync() {
    _syncService.start();
  }

  //Using this when opening app.
  Future<CellsResultBean> updateCurrentIndexCells() async {
    _cellsResultBean = await MyStoreManager.getSyncedCells();
    var updateCellsResult = await UpdateCellsUtils.updateCurrentIndexCells(_hdCore, _cellsResultBean);
    if (updateCellsResult.isChange) {
      _cellsResultBean = updateCellsResult.cellsResultBean;
      await MyStoreManager.syncCells(_cellsResultBean);
    }
    startSync();
    return _cellsResultBean;
  }

  // Using this after import wallet.
  Future<CellsResultBean> getCurrentIndexCells() async {
    _cellsResultBean = await GetCellsUtils.getCurrentIndexCells(_hdCore, 0);
    await MyStoreManager.syncCells(_cellsResultBean);
    startSync();
    return _cellsResultBean;
  }

  //Searching all cells.Include index before current receive index and change index
  Future<CellsResultBean> getWholeHDUnspentCells() async {
    _cellsResultBean = await GetCellsUtils.getWholeHDAllCells(_hdCore);
    await MyStoreManager.syncCells(_cellsResultBean);
    return _cellsResultBean;
  }

  @override
  Future thinBlockUpdate(bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock) async {
    if (isCellsChange) {
      _cellsResultBean = cellsResult;
      await MyStoreManager.syncCells(_cellsResultBean);
      walletCoreInterface.cellsChanged();
    } else {
      _cellsResultBean.syncedBlockNumber = cellsResult.syncedBlockNumber;
      await MyStoreManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    }
    walletCoreInterface.blockChanged();
    return;
  }

  @override
  CellsResultBean getCurrentCellsResult() {
    return _cellsResultBean;
  }
}
