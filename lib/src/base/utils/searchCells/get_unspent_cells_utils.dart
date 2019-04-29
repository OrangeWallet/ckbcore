import 'dart:core';

import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_by_lockhash.dart';

class GetUnspentCellsUtils {
  Future<List<CellBean>> getWholeHD(HDCore hdCore, int targetBlockNumber) async {
    List<CellBean> cells = await _getReceiveAndChange(true, hdCore, targetBlockNumber);
    cells.addAll(await _getReceiveAndChange(false, hdCore, targetBlockNumber));
    return cells;
  }

  Future<List<CellBean>> _getReceiveAndChange(bool isReceive, HDCore hdCore, int targetBlockNumber) async {
    int index;
    if (isReceive) {
      index = hdCore.unusedReceiveWallet.index;
    } else {
      index = hdCore.unusedReceiveWallet.index;
    }
    List<CellBean> cells = List();
    for (int i = 0; i < index; i++) {
      Script lockScript;
      String hdPath;
      if (isReceive) {
        lockScript = hdCore.getReceiveWallet(i).lockScript;
        hdPath = hdCore.getReceiveWallet(i).path;
      } else {
        lockScript = hdCore.getChangeWallet(i).lockScript;
        hdPath = hdCore.getChangeWallet(i).path;
      }
      List<CellBean> newCells =
          await getCellByLockHash(GetCellByLockHashParams(targetBlockNumber, lockScript.scriptHash, hdPath));
      cells.addAll(newCells);
    }
    return cells;
  }

  Future<List<CellBean>> getCurrentIndex(HDCore hdCore, int targetBlockNumber) async {
    List<CellBean> cells = List();

    cells.addAll(await getCellByLockHash(GetCellByLockHashParams(
        targetBlockNumber, hdCore.unusedReceiveWallet.lockScript.scriptHash, hdCore.unusedReceiveWallet.path)));
    cells.addAll(await getCellByLockHash(GetCellByLockHashParams(
        targetBlockNumber, hdCore.unusedReceiveWallet.lockScript.scriptHash, hdCore.unusedChangeWallet.path)));
    return cells;
  }
}
