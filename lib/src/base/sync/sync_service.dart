import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/constant/constant.dart' show ApiClient, IntervalSyncTime;
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/interface/sync_interface.dart';
import 'package:ckbcore/src/base/sync/fetch_thin_block.dart';
import 'package:ckbcore/src/base/sync/handle_synced_cells.dart';
import 'package:ckbcore/src/base/utils/log.dart';

class SyncService {
  CKBApiClient apiClient;
  HDCore hdCore;
  SyncInterface syncInterface;

  SyncService(this.hdCore, this.syncInterface);

  start() async {
    int targetBlockNumber = int.parse(await ApiClient.getTipBlockNumber());
    while (int.parse(syncInterface.getCurrentCellsResult().syncedBlockNumber) < targetBlockNumber) {
      int syncedBlockNumber = int.parse(syncInterface.getCurrentCellsResult().syncedBlockNumber) + 1;
      Log.log('synced is ${syncedBlockNumber - 1},fetch block ${syncedBlockNumber},target is ${targetBlockNumber}');
      var thinBlockWithCellsBean = await fetchBlockToCheckCell(FetchBlockToCheckParam(hdCore, syncedBlockNumber));
      if (thinBlockWithCellsBean.newCells.length > 0 || thinBlockWithCellsBean.spendCells.length > 0) {
        var cells = await handleSyncedCells(syncInterface.getCurrentCellsResult().cells, thinBlockWithCellsBean);
        await syncInterface.thinBlockUpdate(
            true,
            CellsResultBean(cells, thinBlockWithCellsBean.thinBlock.thinHeader.number),
            thinBlockWithCellsBean.thinBlock);
      } else {
        await syncInterface.thinBlockUpdate(false, null, thinBlockWithCellsBean.thinBlock);
      }
    }
    Log.log('synced is ${syncInterface.getCurrentCellsResult().syncedBlockNumber},It`s tip,waiting');
    await Future.delayed(Duration(seconds: IntervalSyncTime), () async {
      await start();
    });
  }
}
