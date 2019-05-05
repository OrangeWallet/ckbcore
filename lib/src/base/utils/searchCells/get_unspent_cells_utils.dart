import 'dart:core';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_by_lockhash.dart';

Future<CellsResultBean> getWholeHDAllCells(HDCore hdCore) async {
  String targetBlockNumber = await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl).getTipBlockNumber();
  List<CellBean> cells = await getWholeHDAllCellsWithTargetNumber(hdCore, int.parse(targetBlockNumber));
  return CellsResultBean(cells, targetBlockNumber);
}

Future<List<CellBean>> getWholeHDAllCellsWithTargetNumber(HDCore hdCore, int targetBlockNumber) async {
  List<CellBean> cells = await _getReceiveAndChangeCells(true, hdCore, 0, targetBlockNumber);
  cells.addAll(await _getReceiveAndChangeCells(false, hdCore, 0, targetBlockNumber));
  return cells;
}

Future<List<CellBean>> _getReceiveAndChangeCells(
    bool isReceive, HDCore hdCore, int startBlockNumber, int targetBlockNumber) async {
  int index;
  if (isReceive) {
    index = hdCore.unusedReceiveWallet.index;
  } else {
    index = hdCore.unusedReceiveWallet.index;
  }
  List<CellBean> cells = List();
  for (int i = 0; i < index; i++) {
    HDIndexWallet hdIndexWallet;
    if (isReceive) {
      hdIndexWallet = hdCore.getReceiveWallet(i);
    } else {
      hdIndexWallet = hdCore.getChangeWallet(i);
    }
    List<CellBean> newCells =
        await getCellByLockHash(GetCellByLockHashParams(startBlockNumber, targetBlockNumber, hdIndexWallet));
    cells.addAll(newCells);
  }
  return cells;
}

Future<CellsResultBean> getCurrentIndexCells(HDCore hdCore, int startBlockNumber) async {
  String targetBlockNumber = await CKBApiClient(nodeUrl: WalletCore.DefaultNodeUrl).getTipBlockNumber();
  List<CellBean> cells =
      await getCurrentIndexCellsWithTargetNumber(hdCore, startBlockNumber, int.parse(targetBlockNumber));
  return CellsResultBean(cells, targetBlockNumber);
}

Future<List<CellBean>> getCurrentIndexCellsWithTargetNumber(
    HDCore hdCore, int startBlockNumber, int targetBlockNumber) async {
  List<CellBean> cells = List();

  cells.addAll(
      await getCellByLockHash(GetCellByLockHashParams(startBlockNumber, targetBlockNumber, hdCore.unusedChangeWallet)));
  cells.addAll(await getCellByLockHash(
      GetCellByLockHashParams(startBlockNumber, targetBlockNumber, hdCore.unusedReceiveWallet)));
  return cells;
}
