import 'dart:typed_data';
import 'package:orange_wallet_core/src/base/coin.dart';

abstract class HDCore {
  Coin _coin;
  int firstUnusedReceiveIndex;
  int firstUnusedChangeIndex;

  HDCore(Uint8List seed, this.firstUnusedReceiveIndex,
      this.firstUnusedChangeIndex) {
    _coin = Coin(seed);
  }

  Future<int> checkTransaction(Uint8List privateKey);

  Future<BigInt> checkUnspentCell(int index, Uint8List privateKey);

  Uint8List getReceivePrivateKey(int index) {
    return _coin.getReceivePrivateKey(index);
  }

  Uint8List getChangePrivateKey(int index) {
    return _coin.getChangePrivateKey(index);
  }

  Uint8List getNextUnusedReceive() {
    return _coin.getReceivePrivateKey(firstUnusedReceiveIndex++);
  }

  Uint8List getNextUnusedChange() {
    return _coin.getChangePrivateKey(firstUnusedChangeIndex++);
  }

  Future fetchAllTransactions() async {
    if (await checkTransaction(getReceivePrivateKey(0)) == 0 &&
        await checkTransaction(getChangePrivateKey(0)) == 0) {
      return;
    }
    await _searchUnusedPrivateKey(0);
    await _searchUnusedPrivateKey(1);
  }

  Future fetchBalance() async {
    for (int i = 0; i < firstUnusedReceiveIndex; i++) {
      await checkUnspentCell(i, getReceivePrivateKey(i));
    }
    for (int x = 0; x < firstUnusedChangeIndex; x++) {
      await checkUnspentCell(x, getChangePrivateKey(x));
    }
  }

  //type: 0 receive 1 change
  Future _searchUnusedPrivateKey(int type) async {
    int deps = 0;
    while (deps < 20) {
      Uint8List privateKey;
      switch (type) {
        case 0:
          firstUnusedReceiveIndex++;
          privateKey = this._coin.getReceivePrivateKey(firstUnusedReceiveIndex);
          break;
        case 1:
          firstUnusedChangeIndex++;
          privateKey = this._coin.getChangePrivateKey(firstUnusedReceiveIndex);
          break;
      }
      if (await checkTransaction(privateKey) == 0) {
        deps++;
      }
    }
    switch (type) {
      case 0:
        firstUnusedReceiveIndex = firstUnusedReceiveIndex - 19;
        break;
      case 1:
        firstUnusedChangeIndex = firstUnusedChangeIndex - 19;
        break;
    }
  }
}
