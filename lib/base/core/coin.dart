import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;

class Coin {
  bip32.BIP32 _node;
  static final _coinType = 309;
  static final _purpose = 44;
  static final _external = 0;
  static final _internal = 1;
  static final _account = 0;

  Coin(Uint8List seed) {
    _node = bip32.BIP32.fromSeed(seed);
  }

  static String getPath(bool isReceive, int index) {
    if (isReceive) {
      return "m/$_purpose'/$_coinType'/$_account'/$_external/$index";
    }
    return "m/$_purpose'/$_coinType'/$_account'/$_internal/$index";
  }

  Uint8List getPathPrivateKey(String path) {
    return _node.derivePath(path).privateKey;
  }

  Uint8List getReceivePrivateKey(int index) {
    return _node.derivePath("m/$_purpose'/$_coinType'/$_account'/$_external/$index").privateKey;
  }

  Uint8List getChangePrivateKey(int index) {
    return _node.derivePath("m/$_purpose'/$_coinType'/$_account'/$_internal/$index").privateKey;
  }
}
