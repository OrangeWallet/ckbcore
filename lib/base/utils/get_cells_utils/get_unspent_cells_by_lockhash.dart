import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/cells_isolate_result.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/hd_index_wallet.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_utils.dart';
import 'package:ckbcore/base/utils/base_isloate.dart';

Future<List<CellBean>> _getCellByLockHash(int from, int to, HDIndexWallet indexWallet) async {
  List<CellBean> cells = [];
  List<CellWithOutPoint> cellsWithOutPoints =
      await ApiClient.getCellsByLockHash(indexWallet.lockScript.scriptHash, from.toString(), to.toString());
  Log.log('from ${from}');
  Log.log('size ${cellsWithOutPoints.length}');
  for (int i = 0; i < cellsWithOutPoints.length; i++) {
    var cellsWithOutPoint = cellsWithOutPoints[i];
    CellBean cell = await fetchThinLiveCell(cellsWithOutPoint, indexWallet.path);
    cells.add(cell);
  }
  return cells;
}

Future<List<CellBean>> getCellByLockHash(
    GetCellByLockHashParams param, Function syncProcess(int start, int target, int current)) async {
  if (param.targetBlockNumber < param.startBlockNumber) {
    throw Exception('StartBlockNumber is bigger then targetBlockNumber');
  }
  int blockNumber = param.startBlockNumber;
  List<CellBean> cells = List();
  while (blockNumber <= param.targetBlockNumber) {
    int from = blockNumber;
    int to = blockNumber + IntervalBlockNumber;
    to = min(to, param.targetBlockNumber);
    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(_handleCellByLockHash, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    CellsIsolateResultBean result = await _sendReceive(from, to, param.hdIndexWallet, sendPort);
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
    HDIndexWallet indexWallet = msg[2];
    SendPort replyTo = msg[3];
    try {
      List<CellBean> newCells = await _getCellByLockHash(from, to, indexWallet);
      var result = CellsIsolateResultBean.fromSuccess(newCells);
      replyTo.send(result);
    } catch (e) {
      var result = CellsIsolateResultBean.fromFail(e.toString());
      replyTo.send(result);
    }
  }
}

Future _sendReceive(int from, int to, HDIndexWallet indexWallet, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([from, to, indexWallet, response.sendPort]);
  return response.first;
}

class GetCellByLockHashParams {
  final int startBlockNumber;
  final int targetBlockNumber;
  final HDIndexWallet hdIndexWallet;

  GetCellByLockHashParams(this.startBlockNumber, this.targetBlockNumber, this.hdIndexWallet);
}
