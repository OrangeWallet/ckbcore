import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/config/sync_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/core/sync_service.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart';

class WalletCore {
  static SyncConfig syncConfig;

  final HDCoreConfig _hdCoreConfig;

  HDCore _hdCore;
  CKBApiClient _apiClient;
  GetUnspentCellsUtils _serachCellsUtils;
  String syncedBlockNumber;
  SyncService _syncService;

  WalletCore(this._hdCoreConfig, {SyncConfig syncConfig, String nodeUrl}) {
    _hdCore = HDCore(_hdCoreConfig);
    _apiClient = CKBApiClient(nodeUrl: nodeUrl);
    _serachCellsUtils = GetUnspentCellsUtils(_apiClient);
    _syncService = SyncService();
  }

  CKBApiClient get apiClient => _apiClient;

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  startSync() async {
    syncedBlockNumber = await _apiClient.getTipBlockNumber();
    _syncService.start();
  }

  //Searching all cells.Include index before current receive index and change index
  Future<CellsResultBean> getWholeHDUnspentCells() async {
    String targetBlockNumber = await _apiClient.getTipBlockNumber();
    var cells = await _serachCellsUtils.getWholeHD(_hdCore, int.parse(targetBlockNumber));
    syncedBlockNumber = targetBlockNumber;
    return CellsResultBean(cells, targetBlockNumber);
  }

  Future<CellsResultBean> getCurrentIndexCells() async {
    String targetBlockNumber = await _apiClient.getTipBlockNumber();
    var cells = await _serachCellsUtils.getCurrentIndex(_hdCore, int.parse(targetBlockNumber));
    syncedBlockNumber = targetBlockNumber;
    return CellsResultBean(cells, targetBlockNumber);
  }
}
