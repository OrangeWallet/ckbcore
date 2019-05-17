import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/crypto/crypto.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb_address/ckb_address.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/core/hd_index_wallet.dart';
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
    HDCoreConfig hdCoreConfig = HDCoreConfig(mnemonic, hex.encode(seed), 0, 0);
    HDIndexWallet myWallet = HDCore(hdCoreConfig).unusedReceiveWallet;

    print("private key>>" + hex.encode(myWallet.privateKey));
    String publicKey = hex.encode(myWallet.publicKey);
    print("public key>>" + publicKey);
    print("compressed public key>>" +
        hex.encode(publicKeyFromPrivate(myWallet.privateKey, compress: true)));
    CKBAddress ckbAddress = CKBAddress(Network.TestNet);
    String address = ckbAddress.generate(publicKey);
    print("Address>>" + address);
    print("blake160>>" + blake160(publicKey));
  });
}
