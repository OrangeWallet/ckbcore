import 'package:bip_bech32/bip_bech32.dart';
import 'package:ckb_sdk/ckb-utils/crypto/hash.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/receiver_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/exception/exception.dart';
import 'package:ckbcore/base/interface/transaction_interface.dart';

class TransactionManager {
  final TransactionInterface _transactionInterface;

  TransactionManager(this._transactionInterface);

  Future<SendTransaction> generateTransaction(
      List<ReceiverBean> receivers, String changeAddress, Network network) async {
    try {
      var contractInfo = await _getContractInfo();
      int needCapacities = 0;
      receivers.forEach((receiver) {
        needCapacities += receiver.capacity;
      });
      if (needCapacities < MinCapacity) {
        throw LessThanMinCapacityException();
      }
      List<Object> cells = _gatherInputs(needCapacities);
      int inputCapacities = cells[0];
      List<SendCellInput> inputs = cells[1];
      List<CellOutput> outputs = receivers.map((receiver) {
        var ckbAddress = CKBAddress(receiver.network);
        Bech32 bech32 = ckbAddress.parse(receiver.address);
        String blake160 = bytesToHex(bech32.data, include0x: true, pad: true);
        return CellOutput(
            receiver.capacity.toString(), '0x', Script(contractInfo[0], [blake160]), null);
      }).toList();
      //change
      if (inputCapacities > needCapacities) {
        CKBAddress ckbAddress = CKBAddress(network);
        Bech32 bech32 = ckbAddress.parse(changeAddress);
        String blake160 = bytesToHex(bech32.data, include0x: true, pad: true);
        outputs.add(CellOutput((inputCapacities - needCapacities).toString(), '0x',
            Script(contractInfo[0], [blake160]), null));
      }
      return SendTransaction(0, [contractInfo[1]], inputs, outputs);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Object>> _getContractInfo() async {
    Transaction sysContract = (await ApiClient.getBlockByBlockNumber('0')).transactions[0];
    CellOutput cellOutput = sysContract.outputs[0];
    String binaryHash = blake2bHexString(cellOutput.data);
    OutPoint(sysContract.hash, 0);
    return [binaryHash, OutPoint(sysContract.hash, 0)];
  }

  List<Object> _gatherInputs(int needCapacities) {
    List<CellBean> cells = _transactionInterface.getCurrentCellsResult().cells;
    List<SendCellInput> inputs = [];
    int inputsCapacities = 0;
    cells.forEach((cell) {
      if (cell.cellOutput.data == '0' && cell.status == CellWithStatus.LIVE) {
        if (inputsCapacities < needCapacities) {
          inputs.add(SendCellInput(cell.outPoint, []));
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
