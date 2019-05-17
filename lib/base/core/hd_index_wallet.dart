import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckb_sdk/ckb-utils/crypto/crypto.dart' as Hash;
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/coin.dart';
import 'package:ckbcore/base/core/credential.dart';

class HDIndexWallet {
  final Credential _credential;
  final bool isReceive;
  final int index;
  String _lockHash;
  String _address;
  String _blake160;

  HDIndexWallet(this._credential, this.isReceive, this.index);

  Uint8List get privateKey => _credential.privateKey;

  Uint8List get publicKey => _credential.publicKey;

  String getAddress(Network network) {
    if (_address == null) _blake160 = _credential.getAddress(network);
    return _address;
  }

  String get path => Coin.getPath(isReceive, index);

  String get blake160 {
    if (_blake160 == null) _blake160 = Hash.blake160(bytesToHex(publicKey));
    return _blake160;
  }

  Script get lockScript {
    Script script = Script(CodeHash, [blake160]);
    return script;
  }

  String get lockHash {
    if (lockHash == null) _lockHash = lockScript.scriptHash;
    return _lockHash;
  }
}
