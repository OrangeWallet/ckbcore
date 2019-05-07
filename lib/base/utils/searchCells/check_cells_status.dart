import 'dart:convert';
import 'dart:isolate';

import 'package:ckb_sdk/ckb-types/item/cell_with_status.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/cells_isolate_result.dart';
import 'package:ckbcore/base/constant/constant.dart';

Future<bool> _checkCellstatus(CellBean cell) async {
  var cellWithStatus = await ApiClient.getLiveCell(cell.outPoint);
  return cellWithStatus.status == CellWithStatus.LIVE;
}

Future<List<CellBean>> _checkCellsStatus(List<CellBean> cells) async {
  List<CellBean> newCells = [];
  for (int i = 0; i < cells.length; i++) {
    if (await _checkCellstatus(cells[i])) newCells.add(cells[i]);
  }
  return newCells;
}

Future<List<CellBean>> checkCellsStatus(List<CellBean> cells) async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_dateLoader, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  CellsIsolateResultBean result = await _sendReceive(cells, sendPort);
  if (result.status) {
    return result.result;
  }
  throw result.errorMessage;
}

_dateLoader(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    List<CellBean> cells = msg[0];
    SendPort replyTo = msg[1];
    try {
      List<CellBean> newCells = await _checkCellsStatus(cells);
      var result = CellsIsolateResultBean.fromSuccess(newCells);
      replyTo.send(result);
    } catch (e) {
      var result = CellsIsolateResultBean.fromFail(jsonEncode(e));
      replyTo.send(result);
    }
  }
}

Future _sendReceive(List<CellBean> cells, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([cells, response.sendPort]);
  return response.first;
}
