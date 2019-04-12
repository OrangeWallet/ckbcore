import 'package:orange_wallet_core/src/base/coin.dart';
import 'dart:typed_data';

abstract class BaseCore {
  Coin _coin;
  int _firstUnusedReceiveIndex;
  int _firstUnusedChangeIndex;

  BaseCore(Uint8List seed, firstUnusedReceiveIndex, firstUnusedChangeIndex) {
    _coin = Coin(seed);
    this._firstUnusedChangeIndex = firstUnusedChangeIndex;
    this._firstUnusedReceiveIndex = firstUnusedReceiveIndex;
  }

  Future<int> checkTransaction(Uint8List privateKey);

  Future<BigInt> checkUnspentCell(Uint8List privateKey);

  Uint8List getReceivePrivateKey(int index) {
    return _coin.getReceivingPrivateKey(index);
  }

  Uint8List getChangePrivateKey(int index) {
    return _coin.getChangePrivateKey(index);
  }

  Future<BigInt> fetchBalance() async {
    if (_firstUnusedChangeIndex == 0 &&
        _firstUnusedReceiveIndex == 0 &&
        await checkTransaction(getReceivePrivateKey(_firstUnusedChangeIndex)) > 0 &&
        await checkTransaction(getChangePrivateKey(_firstUnusedChangeIndex)) > 0) {
      return BigInt.from(0);
    } else {
      await _searchUnusedPrivateKey(0);
      await _searchUnusedPrivateKey(1);
    }
  }

  //type: 0 receive 1 change
  Future _searchUnusedPrivateKey(int type) async {
    int deps = 0;
    while (deps < 20) {
      Uint8List privateKey;
      switch (type) {
        case 0:
          _firstUnusedReceiveIndex++;
          privateKey = this._coin.getReceivingPrivateKey(_firstUnusedReceiveIndex);
          break;
        case 1:
          _firstUnusedChangeIndex++;
          privateKey = this._coin.getChangePrivateKey(_firstUnusedReceiveIndex);
          break;
      }
      if (await checkTransaction(privateKey) > 0) {
        await checkUnspentCell(privateKey);
      } else {
        deps++;
      }
    }
  }
}
