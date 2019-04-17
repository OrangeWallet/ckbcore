import 'dart:typed_data';

import 'package:orange_wallet_core/src/base/coin.dart';
import 'package:orange_wallet_core/src/base/utils/searchTransaction.dart';

class HDCore {
  Coin _coin;
  int _unusedReceiveIndex;
  int _unusedChangeIndex;

  HDCore(Uint8List seed, int unusedReceiveIndex, int unusedChangeIndex) {
    _coin = Coin(seed);
    _unusedReceiveIndex = unusedReceiveIndex;
    _unusedChangeIndex = unusedChangeIndex;
  }

  int get unusedReceiveIndex => _unusedReceiveIndex;

  int get unusedChangeIndex => _unusedChangeIndex;

  String getPath(bool isReceive, int index) {
    return _coin.getPath(isReceive, index);
  }

  Uint8List getReceivePrivateKey(int index) {
    return _coin.getReceivePrivateKey(index);
  }

  Uint8List getChangePrivateKey(int index) {
    return _coin.getChangePrivateKey(index);
  }

  Uint8List getUnusedReceivePrivateKey() {
    return _coin.getReceivePrivateKey(_unusedReceiveIndex);
  }

  Uint8List getUnusedChangePrivateKey() {
    return _coin.getChangePrivateKey(_unusedChangeIndex);
  }

  Future searchUnusedIndex() async {
    if ((await searchTransaction(getReceivePrivateKey(0))).length == 0 &&
        (await searchTransaction(getChangePrivateKey(0))).length == 0) {
      return;
    }
    _unusedReceiveIndex = await _searchUnusedPrivateKey(0);
    _unusedChangeIndex = await _searchUnusedPrivateKey(1);
  }

  //type: 0 receive 1 change
  Future<int> _searchUnusedPrivateKey(int type) async {
    int emptyIndex = 0;
    int index = 0;
    while (emptyIndex < 20) {
      Uint8List privateKey;
      index++;
      switch (type) {
        case 0:
          privateKey = this._coin.getReceivePrivateKey(index);
          break;
        case 1:
          privateKey = this._coin.getChangePrivateKey(index);
          break;
      }
      if ((await searchTransaction(privateKey)).length == 0) {
        emptyIndex++;
      } else {
        emptyIndex = 0;
      }
    }
    index = index - 19;
    return index;
  }
}
