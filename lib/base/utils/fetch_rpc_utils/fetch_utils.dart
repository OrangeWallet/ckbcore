import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckb_sdk/ckb_types.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';

Future<CellOutput> fetchCellOutput(OutPoint outPoint, CKBApiClient apiClient) async {
  TransactionWithStatus transaction = await apiClient.getTransaction(outPoint.cell.txHash);
  if (transaction != null)
    return transaction.transaction.outputs[int.parse(outPoint.cell.index)];
  else
    return null;
}

Future<CellBean> fetchThinLiveCell(
    CellWithOutPoint cellWithOutPoint, CKBApiClient apiClient) async {
  var cellWithStatus = await apiClient.getLiveCell(cellWithOutPoint.outPoint);
  if (cellWithStatus.status == CellWithStatus.LIVE) {
    cellWithStatus.cell.data =
        cellWithStatus.cell.data == '0x' || cellWithStatus.cell.data == '' ? '0' : '1';
    return CellBean(cellWithStatus.cell, cellWithStatus.status, cellWithOutPoint.lock.scriptHash,
        cellWithOutPoint.outPoint);
  } else {
    CellBean cellBean = await fetchThinCell(cellWithOutPoint, apiClient);
    cellBean.status = CellWithStatus.DEAD;
    return null;
  }
}

Future<CellBean> fetchThinCell(CellWithOutPoint cellWithOutPoint, CKBApiClient apiClient) async {
  CellOutput cellOutput = (await apiClient.getTransaction(cellWithOutPoint.outPoint.cell.txHash))
      .transaction
      .outputs[int.parse(cellWithOutPoint.outPoint.cell.index)];
  return CellBean(cellOutput, null, cellOutput.lock.scriptHash, cellWithOutPoint.outPoint);
}

Future<bool> checkCellIsLive(CellBean cell, CKBApiClient apiClient) async {
  var cellWithStatus = await apiClient.getLiveCell(cell.outPoint);
  return cellWithStatus.status == CellWithStatus.LIVE;
}
