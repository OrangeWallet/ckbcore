import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/transaction_with_status.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/constant/constant.dart';

Future<CellOutput> fetchCellOutput(OutPoint outPoint) async {
  TransactionWithStatus transaction = await ApiClient.getTransaction(outPoint.txHash);
  return transaction.transaction.outputs[outPoint.index];
}

Future<CellBean> fetchThinLiveCell(CellWithOutPoint cellWithOutPoint, String path) async {
  var cellWithStatus = await ApiClient.getLiveCell(cellWithOutPoint.outPoint);
  cellWithStatus.cell.data = cellWithStatus.cell.data == '' ? '0' : '1';
  return CellBean(
      cellWithStatus.cell, cellWithStatus.status, cellWithOutPoint.lock.scriptHash, cellWithOutPoint.outPoint, path);
}
