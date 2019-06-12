import 'dart:typed_data';

import 'package:ckb_sdk/ckb_address.dart';
import 'package:ckb_sdk/ckb_crypto.dart';
import 'package:ckb_sdk/ckb_system_contract.dart';
import 'package:ckb_sdk/ckb_types.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/receiver_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/exception/exception.dart';
import 'package:ckbcore/base/interface/transaction_interface.dart';

class TransactionManager {
  final TransactionInterface _impl;
  final Uint8List privateKey;

  TransactionManager(this._impl, this.privateKey);

  Future<String> sendCapacity(List<ReceiverBean> receivers) async {
    Transaction transaction = await generateTransaction(receivers);
    String txHash = await _impl.apiClient.sendTransaction(transaction);
    return txHash;
  }

  Future<Transaction> generateTransaction(List<ReceiverBean> receivers) async {
    try {
      int needCapacities = 0;
      receivers.forEach((receiver) {
        needCapacities += receiver.capacity;
      });
      if (needCapacities < Constant.MinCapacity) {
        throw LessThanMinCapacityException();
      }
      List<Object> cells = gatherInputs(needCapacities);
      int inputCapacities = cells[1];
      List<CellInput> inputs = cells[0];
      List<CellOutput> outputs = receivers.map((receiver) {
        var ckbAddress = CKBAddress(_impl.network);
        String blake160 = hexAdd0x(ckbAddress.blake160FromAddress(receiver.address));
        return CellOutput(
            receiver.capacity.toString(), '0x', Script(Constant.CodeHash, [blake160]), null);
      }).toList();
      SystemContract systemContract = await getSystemContract(_impl.apiClient, _impl.network);
      //change
      if (inputCapacities > needCapacities) {
        String blake160Str = hexAdd0x(blake160(bytesToHex(_impl.myWallet.publicKey)));
        outputs.add(CellOutput((inputCapacities - needCapacities).toString(), '0x',
            Script(Constant.CodeHash, [blake160Str]), null));
      }
      Transaction transaction = Transaction(
          "0", null, [OutPoint(null, systemContract.systemScriptOutPoint)], inputs, outputs, []);
      String txHash = await _impl.apiClient.computeTransactionHash(transaction);
      inputs.forEach((input) => transaction.witnesses = [Witness.sign(privateKey, txHash)]);
      return transaction;
    } catch (e) {
      rethrow;
    }
  }

  List<Object> gatherInputs(int needCapacities) {
    List<CellBean> cells = _impl.cellsResultBean.cells;
    List<CellInput> inputs = [];
    int inputsCapacities = 0;
    cells.forEach((cell) {
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
}
