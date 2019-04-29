import 'dart:isolate';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_status.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';

Future<bool> checkCelltatus(CellBean cell) async {
  var cellWithStatus = await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl).getLiveCell(cell.outPoint);
  return cellWithStatus.status == CellWithStatus.LIVE;
}

Future<List<CellBean>> _checkCellsStatus(List<CellBean> cells) async {
  List<CellBean> newCells = [];
  for (int i = 0; i < cells.length; i++) {
    if (await checkCelltatus(cells[i])) newCells.add(cells[i]);
  }
  return newCells;
}

Future<List<CellBean>> checkCellsStatus(List<CellBean> cells) async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_dateLoader, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  List<CellBean> newCells = await _sendReceive(cells, sendPort);
  return newCells;
}

_dateLoader(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    List<CellBean> cells = msg[0];
    SendPort replyTo = msg[1];
    List<CellBean> newCells = await _checkCellsStatus(cells);
    replyTo.send(newCells);
  }
}

Future _sendReceive(List<CellBean> cells, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([cells, response.sendPort]);
  return response.first;
}
