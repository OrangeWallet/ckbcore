import 'dart:core';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/cell.dart';
import 'package:orange_wallet_core/src/base/bean/utxo_bean.dart';
import 'package:orange_wallet_core/src/base/hd_core/hd_core.dart';

Future<List<UtxoBean>> searchAll(HDCore hdCore) async {
  List<UtxoBean> utxos = await _searchReceiveAndChange(true, hdCore);
  utxos.addAll(await _searchReceiveAndChange(false, hdCore));
  return utxos;
}

Future<List<UtxoBean>> _searchReceiveAndChange(bool isReceive, HDCore hdCore) async {
  int index;
  if (isReceive) {
    index = hdCore.unusedReceiveIndex;
  } else {
    index = hdCore.unusedChangeIndex;
  }
  List<UtxoBean> utxos = List();
  for (int i = 0; i <= index; i++) {
    Uint8List privateKey;
    if (isReceive) {
      privateKey = hdCore.getReceivePrivateKey(i);
    } else {
      privateKey = hdCore.getChangePrivateKey(i);
    }
    List<Cell> newUtxos = await _searchUtxoByPrivateKey(privateKey);
    utxos.addAll(newUtxos.map((cell) => UtxoBean(cell, hdCore.getPath(isReceive, i))));
  }
  return utxos;
}

Future<List<UtxoBean>> searchCurrentIndexUtxos(HDCore hdCore) async {
  List<UtxoBean> utxos = (await _searchUtxoByPrivateKey(hdCore.getUnusedReceivePrivateKey()))
      .map((cell) => UtxoBean(cell, hdCore.getPath(true, hdCore.unusedReceiveIndex)));
  utxos.addAll((await _searchUtxoByPrivateKey(hdCore.getUnusedChangePrivateKey()))
      .map((cell) => UtxoBean(cell, hdCore.getPath(true, hdCore.unusedChangeIndex))));
  return utxos;
}

Future<List<Cell>> _searchUtxoByPrivateKey(Uint8List privateKey) async {
  return List<Cell>(0);
}
