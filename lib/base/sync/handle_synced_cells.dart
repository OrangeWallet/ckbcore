import 'dart:isolate';

import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/cells_isolate_result.dart';
import 'package:ckbcore/base/bean/thin_bolck_with_cells.dart';
import 'package:ckbcore/base/utils/base_isloate.dart';

Future<List<CellBean>> _handleSyncedCells(
    List<CellBean> origanCells, ThinBlockWithCellsBean thinBlockWithCellsBean) async {
  List<CellBean> cells = [];
  cells.addAll(origanCells);
  await Future.forEach(thinBlockWithCellsBean.spendCells, (CellBean spendCell) {
    for (int i = 0; i < cells.length; i++) {
      CellBean cell = cells[i];
      if (spendCell.outPoint.txHash == cell.outPoint.txHash && spendCell.outPoint.index == cell.outPoint.index) {
        cells.removeAt(i);
      }
    }
  });
  cells.addAll(thinBlockWithCellsBean.newCells);
  return cells;
}

Future<List<CellBean>> handleSyncedCells(
    List<CellBean> origanCells, ThinBlockWithCellsBean thinBlockWithCellsBean) async {
  ReceivePort receivePort = ReceivePort();
  isolate = await Isolate.spawn(_sendSyncedCells, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  CellsIsolateResultBean result = await _sendReceive(origanCells, thinBlockWithCellsBean, sendPort);
  destroy();
  if (result.status) {
    return result.result;
  }
  throw result.errorMessage;
}

_sendSyncedCells(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    List<CellBean> origanCells = msg[0];
    ThinBlockWithCellsBean thinBlockWithCellsBean = msg[1];
    SendPort replyTo = msg[2];
    try {
      List<CellBean> newCells = await _handleSyncedCells(origanCells, thinBlockWithCellsBean);
      var result = CellsIsolateResultBean.fromSuccess(newCells);
      replyTo.send(result);
    } catch (e) {
      var result = CellsIsolateResultBean.fromFail(e.toString());
      replyTo.send(result);
    }
  }
}

Future _sendReceive(List<CellBean> origanCells, ThinBlockWithCellsBean thinBlockWithCellsBean, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([origanCells, thinBlockWithCellsBean, response.sendPort]);
  return response.first;
}
