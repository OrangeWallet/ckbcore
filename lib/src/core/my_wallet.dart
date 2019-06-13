import 'dart:typed_data';

import 'package:ckb_sdk/ckb_address.dart';
import 'package:ckb_sdk/ckb_crypto.dart' as crypto;
import 'package:ckb_sdk/ckb_types.dart';

class MyWallet {
  final Uint8List publicKey;
  String _lockHash;
  String _address;
  String _blake160;
  String codeHash;

  MyWallet(this.publicKey) {}

  String getAddress(CKBNetwork network) {
    if (_address == null) _address = CKBAddress(network).generate(crypto.bytesToHex(publicKey));
    return _address;
  }

  String get blake160 {
    if (_blake160 == null) _blake160 = crypto.blake160(crypto.bytesToHex(publicKey));
    return _blake160;
  }

  Script get lockScript {
    Script script = Script(codeHash, [crypto.hexAdd0x(blake160)]);
    return script;
  }

  String get lockHash {
    if (_lockHash == null) _lockHash = lockScript.scriptHash;
    return _lockHash;
  }
}
