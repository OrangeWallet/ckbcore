import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/constant/constant.dart' show ApiClient, IntervalSyncTime;
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/interface/sync_interface.dart';
import 'package:ckbcore/base/sync/handle_synced_cells.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_thin_block.dart';
import 'package:ckbcore/base/utils/log.dart';

class SyncService {
  CKBApiClient apiClient;
  HDCore hdCore;
  SyncInterface syncInterface;
  bool _live = true;
  Function _intercept;

  SyncService(this.hdCore, this.syncInterface);

  start() {
    _live = true;
    _rotation();
  }

  stop(Function intercept) {
    _intercept = intercept;
    _live = false;
  }

  _rotation() async {
    try {
      if (_intercept != null && !_live) {
        _intercept();
        _intercept = null;
        return;
      }
      int targetBlockNumber = int.parse(await ApiClient.getTipBlockNumber());
      while (
          int.parse(syncInterface.getCurrentCellsResult().syncedBlockNumber) < targetBlockNumber &&
              _live) {
        int syncedBlockNumber =
            int.parse(syncInterface.getCurrentCellsResult().syncedBlockNumber) + 1;
        Log.log(
            'synced is ${syncedBlockNumber - 1},fetch block ${syncedBlockNumber},target is ${targetBlockNumber}');
        var thinBlockWithCellsBean =
            await fetchBlockToCheckCell(FetchBlockToCheckParam(hdCore, syncedBlockNumber));
        if (thinBlockWithCellsBean.newCells.length > 0 ||
            thinBlockWithCellsBean.spendCells.length > 0) {
          var cells = await handleSyncedCells(
              syncInterface.getCurrentCellsResult().cells, thinBlockWithCellsBean);
          await syncInterface.thinBlockUpdate(
              true,
              CellsResultBean(cells, thinBlockWithCellsBean.thinBlock.thinHeader.number),
              thinBlockWithCellsBean.thinBlock);
        } else {
          await syncInterface.thinBlockUpdate(false, null, thinBlockWithCellsBean.thinBlock);
        }
      }
      Log.log(
          'synced is ${syncInterface.getCurrentCellsResult().syncedBlockNumber},It`s tip,waiting');
      await Future.delayed(Duration(seconds: IntervalSyncTime), () async {
        await _rotation();
      });
    } catch (e) {
      syncInterface.syncException(e);
    }
  }
}
