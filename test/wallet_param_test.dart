import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/crypto/crypto.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb_address/ckb_address.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  String privateKeyHex = "e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3";
  Uint8List privateKey = hex.decode(privateKeyHex);
  test('wallet from privateKey', () {
    print("private key>>" + privateKeyHex);
    String publicKey = hex.encode(publicKeyFromPrivate(privateKey));
    print("public key>>" + publicKey);
    print("compressed public key>>" + hex.encode(publicKeyFromPrivate(privateKey, compress: true)));
    CKBAddress ckbAddress = CKBAddress(Network.TestNet);
    String address = ckbAddress.generate(publicKey);
    print("Address>>" + address);
    print("blake160>>" + blake160(publicKey));
  });
}
