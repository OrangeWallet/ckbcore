import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/interface/sync_interface.dart';
import 'package:ckbcore/src/base/utils/log.dart';

import 'fetch_thin_block.dart';

class SyncService {
  CKBApiClient apiClient;
  HDCore hdCore;
  SyncInterface syncInterface;

  SyncService(this.hdCore, this.syncInterface) {
    apiClient = CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl);
  }

  start() async {
    int targetBlockNumber = int.parse(await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl).getTipBlockNumber());
    while (int.parse(syncInterface.getCurrentCellsResult().syncedBlockNumber) < targetBlockNumber) {
      int syncedBlockNumber = int.parse(syncInterface.getCurrentCellsResult().syncedBlockNumber) + 1;
      Log.log('synced is ${syncedBlockNumber - 1},fetch block ${syncedBlockNumber},target is ${targetBlockNumber}');
      var thinBlockWithCellsBean = await fetchBlockToCheckCell(FetchBlockToCheckParam(hdCore, syncedBlockNumber));
      if (thinBlockWithCellsBean.newCells.length > 0 || thinBlockWithCellsBean.spendCells.length > 0) {
        List<CellBean> cells = [];
        cells.addAll(syncInterface.getCurrentCellsResult().cells);
        await Future.forEach(thinBlockWithCellsBean.spendCells, (CellBean spendCell) {
          for (int i = 0; i < cells.length; i++) {
            CellBean cell = cells[i];
            if (spendCell.outPoint.txHash == cell.outPoint.txHash && spendCell.outPoint.index == cell.outPoint.index) {
              cells.removeAt(i);
            }
          }
        });
        cells.addAll(thinBlockWithCellsBean.newCells);
        await syncInterface.thinBlockUpdate(
            true,
            CellsResultBean(cells, thinBlockWithCellsBean.thinBlock.thinHeader.number),
            thinBlockWithCellsBean.thinBlock);
      } else {
        await syncInterface.thinBlockUpdate(false, null, thinBlockWithCellsBean.thinBlock);
      }
    }
    Log.log('synced is ${syncInterface.getCurrentCellsResult().syncedBlockNumber},It`s tip,waiting');
    await Future.delayed(Duration(seconds: WalletCore.IntervalSyncTime), () async {
      await start();
    });
  }
}
