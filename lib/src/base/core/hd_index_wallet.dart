import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckbcore/src/base/coin.dart';
import 'package:ckbcore/src/base/core/credential.dart';

class HDIndexWallet {
  final Credential _credential;
  final bool isReceive;
  final int index;

  HDIndexWallet(this._credential, this.isReceive, this.index);

  Uint8List get privateKey => _credential.privateKey;

  Uint8List get publicKey => _credential.publicKey;

  String getAddress(Network network) => _credential.getAddress(network);

  String get path => Coin.getPath(isReceive, index);

  //TODO remove alwaysSccess
  Script get lockScript {
    Script script = Script("", []);
    return script.alwaysSuccess();
  }
}
