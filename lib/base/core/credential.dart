import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/crypto/crypto.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb-utils/number.dart' as number;
import 'package:ckb_sdk/ckb_address/ckb_address.dart';
import 'package:convert/convert.dart';

class Credential {
  final Uint8List privateKey;
  final Uint8List publicKey;

  const Credential._(this.privateKey, this.publicKey);

  static Credential fromPrivateKeyBytes(Uint8List privateKey) {
    Uint8List publicKey = _privateKeyToPublic(privateKey);
    return new Credential._(privateKey, publicKey);
  }

  static Credential fromPrivateKeyHex(String privateKey) {
    return fromPrivateKeyBytes(hex.decode(privateKey));
  }

  static Uint8List _privateKeyToPublic(Uint8List privateKey) {
    return publicKeyFromPrivate(privateKey);
  }

  String getAddress(Network network) {
    return CKBAddress(network).generate(number.bytesToHex(publicKey));
  }
}
