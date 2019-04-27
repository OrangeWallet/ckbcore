import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_outpoint.dart';
import 'package:ckb_sdk/ckb-types/item/cell_with_status.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'dart:math';

class GetUnspentCellsByLockHash {
  Future<List<CellBean>> getCellByLockHash(
      int targetBlockNumber, CKBApiClient apiClient, Script lockHash, String hdPath) async {
    int blockNumber = 0;
    List<CellBean> cells = List();
    while (blockNumber <= targetBlockNumber) {
      int from = blockNumber;
      int to = blockNumber + WalletCore.syncConfig.IntervalBlockNumber;
      to = min(to, targetBlockNumber);
      List<CellWithOutPoint> cellsWithOutPoint =
          await apiClient.getCellsByLockHash(lockHash.scriptHash, from.toString(), to.toString());
      cellsWithOutPoint.forEach((cellsWithOutPoint) async {
        var cellWithStatus = await apiClient.getLiveCell(cellsWithOutPoint.outPoint);
        if (cellWithStatus.status == CellWithStatus.LIVE || cellWithStatus.status == 'created') {
          cells.add(CellBean(
              cellWithStatus.cell, cellWithStatus.status, cellsWithOutPoint.lock, cellsWithOutPoint.outPoint, hdPath));
        }
      });
      blockNumber = to + 1;
    }
    return cells;
  }
}
