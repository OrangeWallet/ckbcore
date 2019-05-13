import 'dart:isolate';

import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/cells_isolate_result.dart';
import 'package:ckbcore/base/utils/base_isloate.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_utils.dart';

Future<List<CellBean>> _checkCellsStatus(List<CellBean> cells, CKBApiClient apiClient) async {
  List<CellBean> newCells = [];
  for (int i = 0; i < cells.length; i++) {
    if (await checkCellIsLive(cells[i], apiClient)) newCells.add(cells[i]);
  }
  return newCells;
}

Future<List<CellBean>> checkCellsStatus(List<CellBean> cells, CKBApiClient apiClient) async {
  ReceivePort receivePort = ReceivePort();
  isolate = await Isolate.spawn(_handleCheckCellsStatus, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  CellsIsolateResultBean result = await _sendReceive(cells, apiClient, sendPort);
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
    CKBApiClient apiClient = msg[1];
    SendPort replyTo = msg[2];
    try {
      List<CellBean> newCells = await _checkCellsStatus(cells, apiClient);
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

Future _sendReceive(List<CellBean> cells, CKBApiClient apiClient, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([cells, apiClient, response.sendPort]);
  return response.first;
}
