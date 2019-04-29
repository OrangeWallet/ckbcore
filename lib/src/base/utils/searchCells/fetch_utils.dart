import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/transaction_with_status.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';

Future<CellOutput> fetchCellOutput(CKBApiClient apiClient, OutPoint outPoint) async {
  TransactionWithStatus transaction = await apiClient.getTransaction(outPoint.txHash);
  return transaction.transaction.outputs[outPoint.index];
}

Future<CellBean> fetchThinLiveCell(CKBApiClient apiClient, CellWithOutPoint cellWithOutPoint, String path) async {
  var cellWithStatus = await apiClient.getLiveCell(cellWithOutPoint.outPoint);
  cellWithStatus.cell.data = cellWithStatus.cell.data == '' ? '0' : '1';
  return CellBean(
      cellWithStatus.cell, cellWithStatus.status, cellWithOutPoint.lock.scriptHash, cellWithOutPoint.outPoint, path);
}
