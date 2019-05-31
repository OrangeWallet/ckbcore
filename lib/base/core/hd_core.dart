import 'dart:typed_data';

import 'package:ckbcore/base/core/coin.dart';
import 'package:ckbcore/base/core/credential.dart';
import 'package:ckbcore/base/core/hd_index_wallet.dart';

class HDCore {
  Coin _coin;
  int _unusedReceiveIndex;
  int _unusedChangeIndex;

  HDCore(Uint8List privateKey, {int unusedReceiveIndex = 0, int unusedChangeIndex = 0}) {
    _coin = Coin(privateKey);
    _unusedReceiveIndex = unusedReceiveIndex;
    _unusedChangeIndex = unusedChangeIndex;
  }

  HDIndexWallet get unusedReceiveWallet {
    if (_unusedReceiveIndex == -1) {
      throw Exception("Please search HD wallet first");
    }
    return getReceiveWallet(_unusedReceiveIndex);
  }

  HDIndexWallet get unusedChangeWallet {
    if (_unusedChangeIndex == -1) {
      throw Exception("Please search HD wallet first");
    }
    return getChangeWallet(_unusedChangeIndex);
  }

  HDIndexWallet getReceiveWallet(int index) {
    return HDIndexWallet(
        Credential.fromPrivateKeyBytes(_coin.getReceivePrivateKey(index)).privateKey,
        isReceive: true,
        index: index);
  }

  HDIndexWallet getChangeWallet(int index) {
    return HDIndexWallet(
        Credential.fromPrivateKeyBytes(_coin.getChangePrivateKey(index)).privateKey,
        isReceive: false,
        index: index);
  }
}
