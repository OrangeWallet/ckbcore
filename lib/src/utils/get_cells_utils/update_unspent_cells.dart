import 'package:ckb_sdk/ckb_rpc.dart';

import '../../bean/cells_result_bean.dart';
import '../../core/my_wallet.dart';
import 'check_cells_status.dart';
import 'get_unspent_cells.dart';

Future<UpdateCellsResult> updateUnspentCells(MyWallet myWallet, CellsResultBean cellsResultBean,
    CKBApiClient apiClient, Function syncProcess(double processing)) async {
  int targetBlockNumber = int.parse(await apiClient.getTipBlockNumber());
  CellsResultBean newCellsResult = CellsResultBean([], "0");
  int syncedBlockNumber = int.parse(cellsResultBean.syncedBlockNumber);
  //if blockNumber need to sync is biger then cells length,we just check all cells we saved and search to target blockNumber
  if ((targetBlockNumber - syncedBlockNumber) * 50 > cellsResultBean.cells.length) {
    newCellsResult.cells.addAll(await checkCellsStatus(cellsResultBean.cells, apiClient));
    newCellsResult.cells.addAll(await getCurrentIndexCellsWithTargetNumber(
        myWallet, syncedBlockNumber, targetBlockNumber, apiClient, syncProcess));
    newCellsResult.syncedBlockNumber = targetBlockNumber.toString();
    return UpdateCellsResult(true, newCellsResult);
  } else {
    return UpdateCellsResult(false, cellsResultBean);
  }
}

class UpdateCellsResult {
  final bool isChange;
  final CellsResultBean cellsResultBean;

  UpdateCellsResult(this.isChange, this.cellsResultBean);
}
