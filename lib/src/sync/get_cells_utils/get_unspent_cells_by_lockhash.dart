import 'dart:isolate';
import 'dart:math';

import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckb_sdk/ckb_types.dart';
import 'package:ckbcore/src/utils/base_isloate.dart';
import 'package:ckbcore/src/utils/log.dart';

import '../../bean/cell_bean.dart';
import '../../bean/isolate_result/cells_isolate_result.dart';
import '../../constant/constant.dart';
import '../fetch_rpc_utils/fetch_utils.dart';

Future<List<CellBean>> _getCellByLockHash(
    int from, int to, String lockHash, CKBApiClient apiClient) async {
  List<CellBean> cells = [];
  List<CellWithOutPoint> cellsWithOutPoints =
      await apiClient.getCellsByLockHash(lockHash, from.toString(), to.toString());
  Log.log('from ${from}');
  Log.log('size ${cellsWithOutPoints.length}');
  for (int i = 0; i < cellsWithOutPoints.length; i++) {
    var cellsWithOutPoint = cellsWithOutPoints[i];
    CellBean cell = await fetchThinLiveCell(cellsWithOutPoint, apiClient);
    if (cell != null) cells.add(cell);
  }
  return cells;
}

Future<List<CellBean>> getCellByLockHash(GetCellByLockHashParams param, CKBApiClient apiClient,
    Function syncProcess(int start, int target, int current)) async {
  if (param.targetBlockNumber < param.startBlockNumber) {
    throw Exception('StartBlockNumber is bigger then targetBlockNumber');
  }
  int blockNumber = param.startBlockNumber;
  List<CellBean> cells = List();
  while (blockNumber <= param.targetBlockNumber) {
    int from = blockNumber;
    int to = blockNumber + Constant.IntervalBlockNumber;
    to = min(to, param.targetBlockNumber);
    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(_handleCellByLockHash, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    CellsIsolateResultBean result =
        await _sendReceive(from, to, param.lockHash, apiClient, sendPort);
    destroy();
    if (result.status) {
      cells.addAll(result.result);
      await syncProcess(param.startBlockNumber, param.targetBlockNumber, to);
    } else {
      throw result.errorMessage;
    }
    blockNumber = to + 1;
  }
  return cells;
}

_handleCellByLockHash(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    int from = msg[0];
    int to = msg[1];
    String lockHash = msg[2];
    CKBApiClient apiClient = msg[3];
    SendPort replyTo = msg[4];
    try {
      List<CellBean> newCells = await _getCellByLockHash(from, to, lockHash, apiClient);
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

Future _sendReceive(int from, int to, String lockHash, CKBApiClient apiClient, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([from, to, lockHash, apiClient, response.sendPort]);
  return response.first;
}

class GetCellByLockHashParams {
  final int startBlockNumber;
  final int targetBlockNumber;
  final String lockHash;

  GetCellByLockHashParams(this.startBlockNumber, this.targetBlockNumber, this.lockHash);
}
