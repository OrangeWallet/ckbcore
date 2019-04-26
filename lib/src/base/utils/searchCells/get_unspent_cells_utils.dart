import 'dart:core';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_by_lockhash.dart';

class GetUnspentCellsUtils with GetUnspentCellsByLockHash {
  final CKBApiClient _apiClient;

  GetUnspentCellsUtils(this._apiClient);

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
    for (int i = 0; i <= index; i++) {
      Script lockScript;
      if (isReceive) {
        lockScript = hdCore.getReceiveWallet(i).lockScript;
      } else {
        lockScript = hdCore.getChangeWallet(i).lockScript;
      }
      List<CellBean> newCells = await getCellByLockHash(
        targetBlockNumber,
        _apiClient,
        lockScript,
      );
      cells.addAll(newCells);
    }
    return cells;
  }

  Future<List<CellBean>> getCurrentIndexCells(HDCore hdCore, int targetBlockNumber) async {
    List<CellBean> cells =
        await getCellByLockHash(targetBlockNumber, _apiClient, hdCore.unusedReceiveWallet.lockScript);
    cells.addAll(await getCellByLockHash(targetBlockNumber, _apiClient, hdCore.unusedChangeWallet.lockScript));
    return cells;
  }
}
