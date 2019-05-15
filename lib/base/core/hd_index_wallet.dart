import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/base/core/coin.dart';
import 'package:ckbcore/base/core/credential.dart';

class HDIndexWallet {
  final Credential _credential;
  final bool isReceive;
  final int index;

  HDIndexWallet(this._credential, this.isReceive, this.index);

  Uint8List get privateKey => _credential.privateKey;

  Uint8List get publicKey => _credential.publicKey;

  String getAddress(Network network) => _credential.getAddress(network);

  String get path => Coin.getPath(isReceive, index);

  //TODO refactor
  Script get lockScript {
    Script script = Script("0000000000000000000000000000000000000000000000000000000000000001",
        [bytesToHex(publicKey)]);
    return script;
  }
}
