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

  Future<BigInt> checkUnspentCell(int index, Uint8List privateKey) {}

  Uint8List getReceivePrivateKey(int index) {
    return _coin.getReceivePrivateKey(index);
  }

  Uint8List getChangePrivateKey(int index) {
    return _coin.getChangePrivateKey(index);
  }

  Uint8List getUnusedReceive() {
    return _coin.getReceivePrivateKey(_unusedReceiveIndex);
  }

  Uint8List getUnusedChange() {
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

  Future fetchBalance() async {
    for (int i = 0; i < _unusedReceiveIndex; i++) {
      await checkUnspentCell(i, getReceivePrivateKey(i));
    }
    for (int x = 0; x < _unusedChangeIndex; x++) {
      await checkUnspentCell(x, getChangePrivateKey(x));
    }
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
