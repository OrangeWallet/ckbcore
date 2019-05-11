import 'dart:core';

import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells_by_lockhash.dart';

// Future<CellsResultBean> getWholeHDAllCells(
//     HDCore hdCore, Function newData(int syncBlockNumber, List<CellBean> cells)) async {
//   String targetBlockNumber = await ApiClient.getTipBlockNumber();
//   List<CellBean> cells = await getWholeHDAllCellsWithTargetNumber(hdCore, int.parse(targetBlockNumber), newData);
//   return CellsResultBean(cells, targetBlockNumber);
// }

// Future<List<CellBean>> getWholeHDAllCellsWithTargetNumber(
//     HDCore hdCore, int targetBlockNumber, Function newData(int syncBlockNumber, List<CellBean> cells)) async {
//   List<CellBean> cells = await _getReceiveAndChangeCells(true, hdCore, 0, targetBlockNumber, newData);
//   cells.addAll(await _getReceiveAndChangeCells(false, hdCore, 0, targetBlockNumber, newData));
//   return cells;
// }

// Future<List<CellBean>> _getReceiveAndChangeCells(bool isReceive, HDCore hdCore, int startBlockNumber,
//     int targetBlockNumber, Function newData(int syncBlockNumber, List<CellBean> cells)) async {
//   int index;
//   if (isReceive) {
//     index = hdCore.unusedReceiveWallet.index;
//   } else {
//     index = hdCore.unusedReceiveWallet.index;
//   }
//   List<CellBean> cells = List();
//   for (int i = 0; i < index; i++) {
//     HDIndexWallet hdIndexWallet;
//     if (isReceive) {
//       hdIndexWallet = hdCore.getReceiveWallet(i);
//     } else {
//       hdIndexWallet = hdCore.getChangeWallet(i);
//     }
//     List<CellBean> newCells =
//         await getCellByLockHash(GetCellByLockHashParams(startBlockNumber, targetBlockNumber, hdIndexWallet), newData);
//     cells.addAll(newCells);
//   }
//   return cells;
// }

Future<CellsResultBean> getCurrentIndexCells(
    HDCore hdCore, int startBlockNumber, Function syncProcess(double processing)) async {
  String targetBlockNumber = await ApiClient.getTipBlockNumber();
  List<CellBean> cells = await getCurrentIndexCellsWithTargetNumber(
      hdCore, startBlockNumber, int.parse(targetBlockNumber), (syncProcess));
  return CellsResultBean(cells, targetBlockNumber);
}

Future<List<CellBean>> getCurrentIndexCellsWithTargetNumber(HDCore hdCore, int startBlockNumber,
    int targetBlockNumber, Function syncProcess(double processing)) async {
  List<CellBean> cells = List();

  // cells.addAll(
  //     await getCellByLockHash(GetCellByLockHashParams(startBlockNumber, targetBlockNumber, hdCore.unusedChangeWallet),
  //         (int start, int target, int current) {
  //   syncProcess((current - start) / ((target - start) * 2));
  // }));
  cells.addAll(await getCellByLockHash(
      GetCellByLockHashParams(startBlockNumber, targetBlockNumber, hdCore.unusedReceiveWallet),
      (int start, int target, int current) {
    syncProcess((current - start) / (target - start));
  }));
  return cells;
}
