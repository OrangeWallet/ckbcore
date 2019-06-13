import 'dart:typed_data';

import 'package:ckb_sdk/ckb_address.dart';
import 'package:ckb_sdk/ckb_crypto.dart';
import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckb_sdk/ckb_system_contract.dart';
import 'package:ckb_sdk/ckb_types.dart';

import '../bean/cell_bean.dart';
import '../bean/receiver_bean.dart';
import '../constant/constant.dart';
import '../exception/exception.dart';

Future<String> sendCapacity(Uint8List privateKey, List<CellBean> cellsBean,
    List<ReceiverBean> receivers, CKBNetwork network) async {
  CKBApiClient _apiClient = CKBApiClient(Constant.NodeUrl);
  Transaction transaction =
      await _generateTransaction(_apiClient, privateKey, cellsBean, receivers, network);
  String txHash = await _apiClient.sendTransaction(transaction);
  return txHash;
}

Future<Transaction> _generateTransaction(CKBApiClient _apiClient, Uint8List privateKey,
    List<CellBean> cellsBean, List<ReceiverBean> receivers, CKBNetwork network) async {
  try {
    int needCapacities = 0;
    receivers.forEach((receiver) {
      needCapacities += receiver.capacity;
    });
    if (needCapacities < MinCapacity) {
      throw LessThanMinCapacityException();
    }
    List<Object> cells = _gatherInputs(cellsBean, needCapacities);
    int inputCapacities = cells[1];
    List<CellInput> inputs = cells[0];
    List<CellOutput> outputs = receivers.map((receiver) {
      var ckbAddress = CKBAddress(network);
      String blake160 = hexAdd0x(ckbAddress.blake160FromAddress(receiver.address));
      return CellOutput(
          receiver.capacity.toString(), '0x', Script(Constant.CodeHash, [blake160]), null);
    }).toList();
    SystemContract systemContract = await getSystemContract(_apiClient, network);
    //change
    if (inputCapacities > needCapacities) {
      String blake160Str = hexAdd0x(blake160(bytesToHex(publicKeyFromPrivate(privateKey))));
      outputs.add(CellOutput((inputCapacities - needCapacities).toString(), '0x',
          Script(Constant.CodeHash, [blake160Str]), null));
    }
    Transaction transaction = Transaction(
        "0", null, [OutPoint(null, systemContract.systemScriptOutPoint)], inputs, outputs, []);
    String txHash = await _apiClient.computeTransactionHash(transaction);
    inputs.forEach((input) => transaction.witnesses = [Witness.sign(privateKey, txHash)]);
    return transaction;
  } catch (e) {
    rethrow;
  }
}

List<Object> _gatherInputs(List<CellBean> cellsBean, int needCapacities) {
  List<CellInput> inputs = [];
  int inputsCapacities = 0;
  cellsBean.forEach((cell) {
    if (cell.cellOutput.data == '0' && cell.status == CellWithStatus.LIVE) {
      if (inputsCapacities < needCapacities) {
        inputs.add(CellInput(cell.outPoint, "0"));
        inputsCapacities += int.parse(cell.cellOutput.capacity);
      } else {
        return;
      }
    }
  });
  if (inputsCapacities < needCapacities) {
    throw NoEnoughCapacityException();
  }
  return [inputs, inputsCapacities];
}
