import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/crypto/crypto.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb_address/ckb_address.dart';
import 'package:ckbcore/base/core/coin.dart';
import 'package:ckbcore/base/core/credential.dart';
import 'package:ckbcore/base/utils/mnemonic_to_seed.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  String privateKeyHex = "3e58f0c69c224bbf90627cd1aabe09c3f8582b1f89a978274af625f54d588521";

  String mnemonic = "afford wisdom bus dutch more acid rent treat alcohol pretty thought usual";

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

  test('wallet from mnemonic', () async {
    Uint8List seed = await mnemonicToSeed(mnemonic);
    Coin coin = Coin(seed);
    Credential credential = Credential.fromPrivateKeyBytes(coin.getReceivePrivateKey(0));

    print("private key>>" + hex.encode(credential.privateKey));
    String publicKey = hex.encode(credential.publicKey);
    print("public key>>" + publicKey);
    print("compressed public key>>" +
        hex.encode(publicKeyFromPrivate(credential.privateKey, compress: true)));
    CKBAddress ckbAddress = CKBAddress(Network.TestNet);
    String address = ckbAddress.generate(publicKey);
    print("Address>>" + address);
    print("blake160>>" + blake160(publicKey));
  });
}
