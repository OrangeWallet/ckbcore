import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_status.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/transaction_with_status.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';

Future<CellOutput> fetchCellOutput(OutPoint outPoint, CKBApiClient apiClient) async {
  TransactionWithStatus transaction = await apiClient.getTransaction(outPoint.cell.txHash);
  if (transaction != null)
    return transaction.transaction.outputs[int.parse(outPoint.cell.index)];
  else
    return null;
}

Future<CellBean> fetchThinLiveCell(
    CellWithOutPoint cellWithOutPoint, String path, CKBApiClient apiClient) async {
  var cellWithStatus = await apiClient.getLiveCell(cellWithOutPoint.outPoint);
  if (cellWithStatus.status == CellWithStatus.LIVE) {
    cellWithStatus.cell.data =
        cellWithStatus.cell.data == '0x' || cellWithStatus.cell.data == '' ? '0' : '1';
    return CellBean(cellWithStatus.cell, cellWithStatus.status, cellWithOutPoint.lock.scriptHash,
        cellWithOutPoint.outPoint, path);
  } else {
    CellBean cellBean = await fetchThinCell(cellWithOutPoint, path, apiClient);
    cellBean.status = CellWithStatus.DEAD;
    return null;
  }
}

Future<CellBean> fetchThinCell(
    CellWithOutPoint cellWithOutPoint, String path, CKBApiClient apiClient) async {
  CellOutput cellOutput = (await apiClient.getTransaction(cellWithOutPoint.outPoint.cell.txHash))
      .transaction
      .outputs[int.parse(cellWithOutPoint.outPoint.cell.index)];
  return CellBean(cellOutput, null, cellOutput.lock.scriptHash, cellWithOutPoint.outPoint, path);
}

Future<bool> checkCellIsLive(CellBean cell, CKBApiClient apiClient) async {
  var cellWithStatus = await apiClient.getLiveCell(cell.outPoint);
  return cellWithStatus.status == CellWithStatus.LIVE;
}
