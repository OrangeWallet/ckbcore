import 'dart:typed_data';

import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckb_sdk/ckb-utils/crypto/crypto.dart' as Hash;
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckb_sdk/ckb_address/ckb_address.dart';
import 'package:ckbcore/base/constant/constant.dart';

class MyWallet {
  final Uint8List publicKey;
  String _lockHash;
  String _address;
  String _blake160;

  MyWallet(this.publicKey) {}

  String getAddress(Network network) {
    if (_address == null) _address = CKBAddress(network).generate(bytesToHex(publicKey));
    return _address;
  }

  String get blake160 {
    if (_blake160 == null) _blake160 = Hash.blake160(bytesToHex(publicKey));
    return _blake160;
  }

  Script get lockScript {
    Script script = Script(Constant.CodeHash, [hexAdd0x(blake160)]);
    return script;
  }

  String get lockHash {
    if (_lockHash == null) _lockHash = lockScript.scriptHash;
    return _lockHash;
  }
}
