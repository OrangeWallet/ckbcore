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
import 'package:ckbcore/base/utils/base_isloate.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_utils.dart';

Future<ThinBlockWithCellsBean> _fetchBlockToCheckCell(FetchBlockToCheckParam param) async {
  Block block = await ApiClient.getBlockByBlockNumber(param.blockNumber.toString());
  var updateCells = ThinBlockWithCellsBean([], [], ThinBlock.fromBlock(block));
  await Future.forEach(block.transactions, (Transaction transaction) async {
    ThinTransaction thinTransaction = ThinTransaction(transaction.hash, 0, 0);
    //caculate spentCells by transaction inputs
    await Future.forEach(transaction.inputs, (CellInput cellInput) async {
      if (cellInput.previousOutput.txHash != null && cellInput.previousOutput.index != null) {
        OutPoint outPoint = OutPoint(cellInput.previousOutput.txHash, cellInput.previousOutput.index);
        CellOutput cellOutput = await fetchCellOutput(outPoint);
        if (cellOutput != null) if (cellOutput.lock.scriptHash ==
            param.hdCore.unusedReceiveWallet.lockScript.scriptHash) {
          CellBean cell = CellBean(null, '', cellOutput.lock.scriptHash, outPoint, '');
          updateCells.spendCells.add(cell);
          thinTransaction.capacityOut = thinTransaction.capacityOut + int.parse(cell.cellOutput.capacity);
        }
      }
    });
    for (int i = 0; i < transaction.outputs.length; i++) {
      CellOutput cellOutput = transaction.outputs[i];
      if (cellOutput.lock.scriptHash == param.hdCore.unusedReceiveWallet.lockScript.scriptHash) {
        updateCells.newCells
            .add(await _fetchCellInOutput(cellOutput, transaction.hash, i, param.hdCore.unusedReceiveWallet));
        thinTransaction.capacityIn = thinTransaction.capacityIn + int.parse(cellOutput.capacity);
      }
    }
    if (thinTransaction.capacityOut > 0 || thinTransaction.capacityIn > 0)
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
  isolate = await Isolate.spawn(_sendBlock, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  ThinBlockIsolateResultBean result = await _sendReceive(param, sendPort);
  destroy();
  if (result.status) {
    return result.result;
  }
  throw result.errorMessage;
}

_sendBlock(SendPort sendPort) async {
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
