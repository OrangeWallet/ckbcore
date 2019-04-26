import 'dart:typed_data';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
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
  String _syncBlockNumber;
  SyncService _syncService;

  WalletCore._(this._hdCoreConfig, {String nodeUrl}) {
    _hdCore = HDCore(_hdCoreConfig);
    _apiClient = CKBApiClient(nodeUrl: nodeUrl);
    _serachCellsUtils = GetUnspentCellsUtils(_apiClient);
    _syncService = SyncService();
  }

  CKBApiClient get apiClient => _apiClient;

  static WalletCore fromImport(Uint8List seed, {SyncConfig syncConfig, String nodeUrl}) {
    WalletCore.syncConfig = syncConfig;
    return WalletCore._(HDCoreConfig(seed, -1, -1));
  }

  static fromCreate(Uint8List seed, {SyncConfig syncConfig, String nodeUrl}) {
    WalletCore.syncConfig = syncConfig;
    return WalletCore._(HDCoreConfig(seed, 0, 0));
  }

  static fromStore(HDCoreConfig hdCoreConfig, {SyncConfig syncConfig, String nodeUrl}) {
    WalletCore.syncConfig = syncConfig;
    return WalletCore._(hdCoreConfig);
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  startSync() async {
    _syncBlockNumber = await _apiClient.getTipBlockNumber();
    _syncService.start();
  }

  //Searching all cells.Include index before current receive index and change index
  Future<List<CellBean>> getWholeHDUnspentCells() async {
    return await _serachCellsUtils.getWholeHD(_hdCore, int.parse(await _apiClient.getTipBlockNumber()));
  }

  //Searching current index cells
  Future<List<CellBean>> getCurrentUnspentCells() async {
    return await _serachCellsUtils.getCurrentIndexCells(_hdCore, int.parse(await _apiClient.getTipBlockNumber()));
  }
}
