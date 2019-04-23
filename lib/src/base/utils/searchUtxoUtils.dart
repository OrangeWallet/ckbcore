import 'dart:core';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/cell.dart';
import 'package:orange_wallet_core/src/base/bean/utxo_bean.dart';
import 'package:orange_wallet_core/src/base/coin.dart';
import 'package:orange_wallet_core/src/base/core/hd_core.dart';

Future<List<UtxoBean>> searchAll(HDCore hdCore) async {
  List<UtxoBean> utxos = await _searchReceiveAndChange(true, hdCore);
  utxos.addAll(await _searchReceiveAndChange(false, hdCore));
  return utxos;
}

Future<List<UtxoBean>> _searchReceiveAndChange(bool isReceive, HDCore hdCore) async {
  int index;
  if (isReceive) {
    index = hdCore.unusedReceiveWallet.index;
  } else {
    index = hdCore.unusedReceiveWallet.index;
  }
  List<UtxoBean> utxos = List();
  for (int i = 0; i <= index; i++) {
    Uint8List privateKey;
    if (isReceive) {
      privateKey = hdCore.getReceiveWallet(i).privateKey;
    } else {
      privateKey = hdCore.getChangeWallet(i).privateKey;
    }
    List<Cell> newUtxos = await _searchUtxoByPrivateKey(privateKey);
    utxos.addAll(newUtxos.map((cell) => UtxoBean(cell, Coin.getPath(isReceive, i))));
  }
  return utxos;
}

Future<List<UtxoBean>> searchCurrentIndexUtxos(HDCore hdCore) async {
  List<UtxoBean> utxos = (await _searchUtxoByPrivateKey(hdCore.unusedReceiveWallet.privateKey))
      .map((cell) => UtxoBean(cell, Coin.getPath(true, hdCore.unusedReceiveWallet.index)));
  utxos.addAll((await _searchUtxoByPrivateKey(hdCore.unusedChangeWallet.privateKey))
      .map((cell) => UtxoBean(cell, Coin.getPath(true, hdCore.unusedChangeWallet.index))));
  return utxos;
}

Future<List<Cell>> _searchUtxoByPrivateKey(Uint8List privateKey) async {
  return List<Cell>(0);
}
