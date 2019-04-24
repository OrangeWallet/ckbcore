import 'dart:core';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/cell.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/coin.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';

Future<List<CellBean>> searchAll(HDCore hdCore) async {
  List<CellBean> cells = await _searchReceiveAndChange(true, hdCore);
  cells.addAll(await _searchReceiveAndChange(false, hdCore));
  return cells;
}

Future<List<CellBean>> _searchReceiveAndChange(bool isReceive, HDCore hdCore) async {
  int index;
  if (isReceive) {
    index = hdCore.unusedReceiveWallet.index;
  } else {
    index = hdCore.unusedReceiveWallet.index;
  }
  List<CellBean> cells = List();
  for (int i = 0; i <= index; i++) {
    Uint8List privateKey;
    if (isReceive) {
      privateKey = hdCore.getReceiveWallet(i).privateKey;
    } else {
      privateKey = hdCore.getChangeWallet(i).privateKey;
    }
    List<Cell> newCells = await _searchCellByPrivateKey(privateKey);
    cells.addAll(newCells.map((cell) => CellBean(cell, Coin.getPath(isReceive, i))));
  }
  return cells;
}

Future<List<CellBean>> searchCurrentIndexCells(HDCore hdCore) async {
  List<CellBean> cells = (await _searchCellByPrivateKey(hdCore.unusedReceiveWallet.privateKey))
      .map((cell) => CellBean(cell, Coin.getPath(true, hdCore.unusedReceiveWallet.index)));
  cells.addAll((await _searchCellByPrivateKey(hdCore.unusedChangeWallet.privateKey))
      .map((cell) => CellBean(cell, Coin.getPath(true, hdCore.unusedChangeWallet.index))));
  return cells;
}

Future<List<Cell>> _searchCellByPrivateKey(Uint8List privateKey) async {
  return List<Cell>(0);
}
