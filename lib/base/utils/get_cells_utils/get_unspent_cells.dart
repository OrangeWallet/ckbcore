import 'dart:core';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/core/my_wallet.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells_by_lockhash.dart';

Future<CellsResultBean> getCurrentIndexCells(MyWallet myWallet, int startBlockNumber,
    CKBApiClient apiClient, Function syncProcess(double processing)) async {
  String targetBlockNumber = await apiClient.getTipBlockNumber();
  List<CellBean> cells = await getCurrentIndexCellsWithTargetNumber(
      myWallet, startBlockNumber, int.parse(targetBlockNumber), apiClient, syncProcess);
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
