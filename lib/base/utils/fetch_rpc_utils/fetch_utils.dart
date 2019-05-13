import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_status.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/transaction_with_status.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';

Future<CellOutput> fetchCellOutput(OutPoint outPoint) async {
  TransactionWithStatus transaction =
      await CKBApiClient(NodeUrl).getTransaction(outPoint.cell.txHash);
  if (transaction != null)
    return transaction.transaction.outputs[int.parse(outPoint.cell.index)];
  else
    return null;
}

Future<CellBean> fetchThinLiveCell(CellWithOutPoint cellWithOutPoint, String path) async {
  var cellWithStatus = await CKBApiClient(NodeUrl).getLiveCell(cellWithOutPoint.outPoint);
  cellWithStatus.cell.data =
      cellWithStatus.cell.data == '0x' || cellWithStatus.cell.data == '' ? '0' : '1';
  return CellBean(cellWithStatus.cell, cellWithStatus.status, cellWithOutPoint.lock.scriptHash,
      cellWithOutPoint.outPoint, path);
}

Future<bool> checkCellIsLive(CellBean cell) async {
  var cellWithStatus = await CKBApiClient(NodeUrl).getLiveCell(cell.outPoint);
  return cellWithStatus.status == CellWithStatus.LIVE;
}
