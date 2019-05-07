import 'dart:isolate';

import 'package:ckb_sdk/ckb-types/res_export.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/thin_block_isolate_result.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/bean/thin_bolck_with_cells.dart';
import 'package:ckbcore/base/bean/thin_transaction.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/core/hd_index_wallet.dart';
import 'package:ckbcore/base/utils/searchCells/fetch_utils.dart';

Future<ThinBlockWithCellsBean> _fetchBlockToCheckCell(FetchBlockToCheckParam param) async {
  String blockHash = await ApiClient.getBlockHash(param.blockNumber.toString());
  Block block = await ApiClient.getBlock(blockHash);
  var updateCells = ThinBlockWithCellsBean([], [], ThinBlock.fromBlock(block));
  await Future.forEach(block.transactions, (Transaction transaction) async {
    ThinTransaction thinTransaction = ThinTransaction(transaction.hash, [], []);
    await Future.forEach(transaction.inputs, (CellInput cellInput) async {
      if (cellInput.previousOutput.txHash != null && cellInput.previousOutput.index != null) {
        OutPoint outPoint = OutPoint(cellInput.previousOutput.txHash, cellInput.previousOutput.index);
        CellOutput cellOutput = await fetchCellOutput(outPoint);
        if (cellOutput != null) if (cellOutput.lock.scriptHash ==
                param.hdCore.unusedChangeWallet.lockScript.scriptHash ||
            cellOutput.lock.scriptHash == param.hdCore.unusedReceiveWallet.lockScript.scriptHash) {
          CellBean cell = CellBean(null, '', cellOutput.lock.scriptHash, outPoint, '');
          updateCells.spendCells.add(cell);
          ThinCell thinCell = ThinCell(cellOutput.capacity, cellOutput.lock);
          thinTransaction.cellsInputs.add(thinCell);
        }
      }
    });
    for (int i = 0; i < transaction.outputs.length; i++) {
      CellOutput cellOutput = transaction.outputs[i];
      if (cellOutput.lock.scriptHash == param.hdCore.unusedChangeWallet.lockScript.scriptHash) {
        updateCells.newCells
            .add(await _fetchCellInOutput(cellOutput, transaction.hash, i, param.hdCore.unusedChangeWallet));
        ThinCell thinCell = ThinCell(cellOutput.capacity, cellOutput.lock);
        thinTransaction.cellsOutputs.add(thinCell);
      }
      if (cellOutput.lock.scriptHash == param.hdCore.unusedReceiveWallet.lockScript.scriptHash) {
        updateCells.newCells
            .add(await _fetchCellInOutput(cellOutput, transaction.hash, i, param.hdCore.unusedReceiveWallet));
        ThinCell thinCell = ThinCell(cellOutput.capacity, cellOutput.lock);
        thinTransaction.cellsOutputs.add(thinCell);
      }
    }
    if (thinTransaction.cellsInputs.length > 0 || thinTransaction.cellsOutputs.length > 0)
      updateCells.thinBlock.thinTrans.add(thinTransaction);
  });
  return updateCells;
}

Future<CellBean> _fetchCellInOutput(CellOutput cellOutput, String txHash, int index, HDIndexWallet wallet) async {
  CellWithOutPoint cellWithOutPoint = CellWithOutPoint(cellOutput.capacity, wallet.lockScript, OutPoint(txHash, index));
  return await fetchThinLiveCell(cellWithOutPoint, wallet.path);
}

class FetchBlockToCheckParam {
  final HDCore hdCore;
  final int blockNumber;
  FetchBlockToCheckParam(this.hdCore, this.blockNumber);
}

Future<ThinBlockWithCellsBean> fetchBlockToCheckCell(FetchBlockToCheckParam param) async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_dateLoader, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  ThinBlockIsolateResultBean result = await _sendReceive(param, sendPort);
  if (result.status) {
    return result.result;
  }
  throw result.errorMessage;
}

_dateLoader(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    FetchBlockToCheckParam param = msg[0];
    SendPort replyTo = msg[1];
    try {
      ThinBlockWithCellsBean result = await _fetchBlockToCheckCell(param);
      ThinBlockIsolateResultBean resultBean = ThinBlockIsolateResultBean.fromSuccess(result);
      replyTo.send(resultBean);
    } catch (e) {
      ThinBlockIsolateResultBean resultBean = ThinBlockIsolateResultBean.fromFail(e.toString());
      replyTo.send(resultBean);
    }
  }
}

Future _sendReceive(FetchBlockToCheckParam param, SendPort port) {
  ReceivePort response = ReceivePort();
  port.send([param, response.sendPort]);
  return response.first;
}
