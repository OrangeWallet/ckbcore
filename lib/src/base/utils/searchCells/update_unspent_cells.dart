import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/utils/searchCells/check_cells_status.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart';

Future<UpdateCellsResult> updateCurrentIndexCells(
    HDCore hdCore, CellsResultBean cellsResultBean, int targetBlockNumber) async {
  CellsResultBean newCellsResult = CellsResultBean([], "0");
  int syncedBlockNumber = int.parse(cellsResultBean.syncedBlockNumber);
  //if blockNumber need to sync is biger then cells length,we just check all cells we saved and search to target blockNumber
  if (targetBlockNumber - syncedBlockNumber > cellsResultBean.cells.length) {
    newCellsResult.cells.addAll(await checkCellsStatus(cellsResultBean.cells));
    newCellsResult.cells.addAll(await getCurrentIndexCells(hdCore, syncedBlockNumber, targetBlockNumber));
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
