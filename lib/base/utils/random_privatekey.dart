import 'dart:math';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/base/utils/random_bridge.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';

Uint8List createRandonPrivateKey() {
  final ECDomainParameters _params = ECCurve_secp256k1();
  final generator = ECKeyGenerator();

  final keyParams = ECKeyGeneratorParameters(_params);

  generator.init(ParametersWithRandom(keyParams, RandomBridge(Random.secure())));

  final key = generator.generateKeyPair();
  final ecPrivateKey = key.privateKey as ECPrivateKey;
  return numberToBytes(ecPrivateKey.d);
}
