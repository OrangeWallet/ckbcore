import 'dart:isolate';
import 'dart:math';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';

Future<List<CellBean>> _getCellByLockHash(GetCellByLockHashParams param) async {
  int blockNumber = 0;
  List<CellBean> cells = List();
  while (blockNumber <= param.targetBlockNumber) {
    int from = blockNumber;
    int to = blockNumber + WalletCore.IntervalBlockNumber;
    to = min(to, param.targetBlockNumber);
    List<CellWithOutPoint> cellsWithOutPoints = await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl)
        .getCellsByLockHash(param.lockHash, from.toString(), to.toString());
    for (int i = 0; i < cellsWithOutPoints.length; i++) {
      var cellsWithOutPoint = cellsWithOutPoints[i];
      var cellWithStatus =
          await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl).getLiveCell(cellsWithOutPoint.outPoint);
      cellWithStatus.cell.data = cellWithStatus.cell.data == '' ? '0' : '1';
      cells.add(CellBean(cellWithStatus.cell, cellWithStatus.status, cellsWithOutPoint.lock.scriptHash,
          cellsWithOutPoint.outPoint, param.hdPath));
    }
    blockNumber = to + 1;
  }
  return cells;
}

getCellByLockHash(GetCellByLockHashParams param) async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_dateLoader, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  List<CellBean> cells = await _sendReceive(param, sendPort);
  return cells;
}

_dateLoader(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    GetCellByLockHashParams param = msg[0];
    SendPort replyTo = msg[1];
    List<CellBean> cells = await _getCellByLockHash(param);
    replyTo.send(cells);
  }
}

Future _sendReceive(GetCellByLockHashParams param, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([param, response.sendPort]);
  return response.first;
}

class GetCellByLockHashParams {
  final int targetBlockNumber;
  final String lockHash;
  final String hdPath;

  GetCellByLockHashParams(this.targetBlockNumber, this.lockHash, this.hdPath);
}
