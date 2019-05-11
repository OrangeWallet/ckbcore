import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/utils/get_cells_utils/check_cells_status.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells.dart';

Future<UpdateCellsResult> updateUnspentCells(
    HDCore hdCore, CellsResultBean cellsResultBean, Function syncProcess(double processing)) async {
  int targetBlockNumber = int.parse(await CKBApiClient(NodeUrl).getTipBlockNumber());
  CellsResultBean newCellsResult = CellsResultBean([], "0");
  int syncedBlockNumber = int.parse(cellsResultBean.syncedBlockNumber);
  //if blockNumber need to sync is biger then cells length,we just check all cells we saved and search to target blockNumber
  if ((targetBlockNumber - syncedBlockNumber) * 50 > cellsResultBean.cells.length) {
    newCellsResult.cells.addAll(await checkCellsStatus(cellsResultBean.cells));
    newCellsResult.cells.addAll(await getCurrentIndexCellsWithTargetNumber(
        hdCore, syncedBlockNumber, targetBlockNumber, syncProcess));
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
