import 'dart:isolate';

import '../bean/cell_bean.dart';
import '../bean/isolate_result/cells_isolate_result.dart';
import '../bean/thin_bolck_with_cells.dart';
import '../utils/base_isloate.dart';

Future<List<CellBean>> _handleSyncedCells(
    List<CellBean> originCells, ThinBlockWithCellsBean thinBlockWithCellsBean) async {
  List<CellBean> cells = [];
  cells.addAll(originCells);
  await Future.forEach(thinBlockWithCellsBean.spendCells, (CellBean spendCell) {
    for (int i = 0; i < cells.length; i++) {
      CellBean cell = cells[i];
      if (spendCell.outPoint.cell.txHash == cell.outPoint.cell.txHash &&
          spendCell.outPoint.cell.index == cell.outPoint.cell.index) {
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
      var result = CellsIsolateResultBean.fromFail(e);
      replyTo.send(result);
    }
  }
}

Future _sendReceive(
    List<CellBean> origanCells, ThinBlockWithCellsBean thinBlockWithCellsBean, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([origanCells, thinBlockWithCellsBean, response.sendPort]);
  return response.first;
}
