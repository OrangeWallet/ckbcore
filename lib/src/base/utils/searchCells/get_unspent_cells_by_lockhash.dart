import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/isolate_result/cells_isolate_result.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/utils/log.dart';
import 'package:ckbcore/src/base/utils/searchCells/fetch_utils.dart';

Future<List<CellBean>> _getCellByLockHash(GetCellByLockHashParams param) async {
  if (param.targetBlockNumber < param.startBlockNumber) {
    throw Exception('StartBlockNumber is bigger then targetBlockNumber');
  }
  int blockNumber = param.startBlockNumber;
  List<CellBean> cells = List();
  while (blockNumber <= param.targetBlockNumber) {
    int from = blockNumber;
    int to = blockNumber + WalletCore.IntervalBlockNumber;
    to = min(to, param.targetBlockNumber);
    List<CellWithOutPoint> cellsWithOutPoints = await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl)
        .getCellsByLockHash(param.hdIndexWallet.lockScript.scriptHash, from.toString(), to.toString());
    Log.log('from ${from}');
    Log.log('size ${cellsWithOutPoints.length}');
    for (int i = 0; i < cellsWithOutPoints.length; i++) {
      var cellsWithOutPoint = cellsWithOutPoints[i];
      CellBean cell = await fetchThinLiveCell(
          CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl), cellsWithOutPoint, param.hdIndexWallet.path);
      cells.add(cell);
    }
    blockNumber = to + 1;
  }
  return cells;
}

Future<List<CellBean>> getCellByLockHash(GetCellByLockHashParams param) async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_dateLoader, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  CellsIsolateResultBean result = await _sendReceive(param, sendPort);
  if (result.status) {
    return result.result;
  }
  throw result.errorMessage;
}

_dateLoader(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    GetCellByLockHashParams param = msg[0];
    SendPort replyTo = msg[1];
    try {
      List<CellBean> newCells = await _getCellByLockHash(param);
      var result = CellsIsolateResultBean.fromSuccess(newCells);
      replyTo.send(result);
    } catch (e) {
      var result = CellsIsolateResultBean.fromFail(jsonEncode(e));
      replyTo.send(result);
    }
  }
}

Future _sendReceive(GetCellByLockHashParams param, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([param, response.sendPort]);
  return response.first;
}

class GetCellByLockHashParams {
  final int startBlockNumber;
  final int targetBlockNumber;
  final HDIndexWallet hdIndexWallet;

  GetCellByLockHashParams(this.startBlockNumber, this.targetBlockNumber, this.hdIndexWallet);
}
