import 'dart:isolate';

import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/cells_isolate_result.dart';
import 'package:ckbcore/base/utils/base_isloate.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_utils.dart';

Future<List<CellBean>> _checkCellsStatus(List<CellBean> cells) async {
  List<CellBean> newCells = [];
  for (int i = 0; i < cells.length; i++) {
    if (await checkCellIsLive(cells[i])) newCells.add(cells[i]);
  }
  return newCells;
}

Future<List<CellBean>> checkCellsStatus(List<CellBean> cells) async {
  ReceivePort receivePort = ReceivePort();
  isolate = await Isolate.spawn(_handleCheckCellsStatus, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  CellsIsolateResultBean result = await _sendReceive(cells, sendPort);
  destroy();
  if (result.status) {
    return result.result;
  }
  throw result.errorMessage;
}

_handleCheckCellsStatus(SendPort sendPort) async {
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
      var result;
      if (e is Exception) {
        result = CellsIsolateResultBean.fromFail(e);
      } else {
        result = CellsIsolateResultBean.fromFail(Exception(e.toString()));
      }
      replyTo.send(result);
    }
  }
}

Future _sendReceive(List<CellBean> cells, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([cells, response.sendPort]);
  return response.first;
}
