import 'dart:typed_data';

import 'package:ckbcore/src/base/coin.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/credential.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/utils/searchTransaction.dart';

class HDCore {
  Coin _coin;
  int _unusedReceiveIndex;
  int _unusedChangeIndex;

  HDCore(HDCoreConfig config) {
    _coin = Coin(config.seed);
    _unusedReceiveIndex = config.receiveIndex;
    _unusedChangeIndex = config.changeIndex;
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
    return HDIndexWallet(Credential.fromPrivateKeyBytes(_coin.getReceivePrivateKey(index)), true, index);
  }

  HDIndexWallet getChangeWallet(int index) {
    return HDIndexWallet(Credential.fromPrivateKeyBytes(_coin.getChangePrivateKey(index)), false, index);
  }

  Future searchUnusedIndex() async {
    if ((await searchTransaction(getReceiveWallet(0).privateKey)).length == 0 &&
        (await searchTransaction(getChangeWallet(0).privateKey)).length == 0) {
      return;
    }
    _unusedReceiveIndex = await _searchUnusedIndex(0);
    _unusedChangeIndex = await _searchUnusedIndex(1);
  }

  //type: 0 receive 1 change
  Future<int> _searchUnusedIndex(int type) async {
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
