import 'dart:core';

import 'package:ckb_sdk/ckb_rpc.dart';

import '../../bean/cell_bean.dart';
import '../../bean/cells_result_bean.dart';
import '../../core/my_wallet.dart';
import 'get_unspent_cells_by_lockhash.dart';

Future<CellsResultBean> getCurrentIndexCells(MyWallet myWallet, int startBlockNumber,
    CKBApiClient apiClient, Function syncProcess(double processing)) async {
  String targetBlockNumber = await apiClient.getTipBlockNumber();
  List<CellBean> cells = await getCurrentIndexCellsWithTargetNumber(
      myWallet, startBlockNumber, int.parse(targetBlockNumber), apiClient, syncProcess);
  print(myWallet.lockHash);
  return CellsResultBean(cells, targetBlockNumber);
}

Future<List<CellBean>> getCurrentIndexCellsWithTargetNumber(MyWallet myWallet, int startBlockNumber,
    int targetBlockNumber, CKBApiClient apiClient, Function syncProcess(double processing)) async {
  List<CellBean> cells = List();

  cells.addAll(await getCellByLockHash(
      GetCellByLockHashParams(startBlockNumber, targetBlockNumber, myWallet), apiClient,
      (int start, int target, int current) {
    syncProcess((current - start) / (target - start));
  }));
  return cells;
}
