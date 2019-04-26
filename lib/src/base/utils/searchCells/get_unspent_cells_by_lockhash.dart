import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';

class GetUnspentCellsByLockHash {
  final IntervalBlockNumber = 100;

  Future<List<CellBean>> getCellByLockHash(int targetBlockNumber, CKBApiClient apiClient, Script lockHash) async {
    int blockNumber = 0;
    while (blockNumber < targetBlockNumber) {}
    return List<CellBean>(0);
  }
}
