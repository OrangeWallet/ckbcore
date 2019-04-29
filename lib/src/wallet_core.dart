import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/config/sync_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/core/sync_service.dart';
import 'package:ckbcore/src/base/store/store_manager.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart';

class WalletCore {
  static SyncConfig MySyncConfig;
  static String MyStorePath;
  static StoreManager MyStoreManager;

  final HDCoreConfig _hdCoreConfig;

  HDCore _hdCore;
  CKBApiClient _apiClient;
  GetUnspentCellsUtils _serachCellsUtils;
  SyncService _syncService;

  WalletCore(this._hdCoreConfig, String storePath, {SyncConfig syncConfig, String nodeUrl}) {
    MyStorePath = storePath;
    MySyncConfig = syncConfig;
    _hdCore = HDCore(_hdCoreConfig);
    _apiClient = CKBApiClient(nodeUrl: nodeUrl);
    _serachCellsUtils = GetUnspentCellsUtils(_apiClient);
    _syncService = SyncService();
  }

  CKBApiClient get apiClient => _apiClient;

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  startSync() async {
    _syncService.start();
  }

  Future<CellsResultBean> updateCurrentIndexCells() async {}

  Future getCurrentIndexCells() async {
    String targetBlockNumber = await _apiClient.getTipBlockNumber();
    var cells = await _serachCellsUtils.getCurrentIndex(_hdCore, int.parse(targetBlockNumber));
    await MyStoreManager.syncCells(targetBlockNumber, cells);
    return;
  }

  //Searching all cells.Include index before current receive index and change index
  Future getWholeHDUnspentCells() async {
    String targetBlockNumber = await _apiClient.getTipBlockNumber();
    var cells = await _serachCellsUtils.getWholeHD(_hdCore, int.parse(targetBlockNumber));
    MyStoreManager.syncCells(targetBlockNumber, cells);
    return;
  }
}
