import 'dart:core';

import 'package:ckb_sdk/ckb_rpc.dart';

import '../../bean/cell_bean.dart';
import '../../bean/cells_result_bean.dart';
import 'get_unspent_cells_by_lockhash.dart';

Future<CellsResultBean> getCurrentIndexCells(String lockHash, int startBlockNumber,
    CKBApiClient apiClient, Function syncProcess(double processing)) async {
  String targetBlockNumber = await apiClient.getTipBlockNumber();
  List<CellBean> cells = await getCurrentIndexCellsWithTargetNumber(
      lockHash, startBlockNumber, int.parse(targetBlockNumber), apiClient, syncProcess);
  return CellsResultBean(cells, targetBlockNumber);
}

Future<List<CellBean>> getCurrentIndexCellsWithTargetNumber(String lockHash, int startBlockNumber,
    int targetBlockNumber, CKBApiClient apiClient, Function syncProcess(double processing)) async {
  List<CellBean> cells = List();

  cells.addAll(await getCellByLockHash(
      GetCellByLockHashParams(startBlockNumber, targetBlockNumber, lockHash), apiClient,
      (int start, int target, int current) {
    syncProcess((current - start) / (target - start));
  }));
  return cells;
}
