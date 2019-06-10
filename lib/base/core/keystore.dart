/**
Copyright 2019 Simon Binder

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/crypto/keccac.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckb_sdk/ckb-utils/typed_data.dart';
import 'package:ckbcore/base/utils/random_bridge.dart';
import 'package:ckbcore/base/utils/uuid.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/stream/ctr.dart';

abstract class _KeyDerivator {
  Uint8List deriveKey(Uint8List password);

  String get name;
  Map<String, dynamic> encode();
}

class _PBDKDF2KeyDerivator extends _KeyDerivator {
  final int iterations;
  final Uint8List salt;
  final int dklen;

  // The docs (https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition)
  // say that HMAC with SHA-256 is the only mac supported at the moment
  static final Mac mac = HMac(SHA256Digest(), 64);

  _PBDKDF2KeyDerivator(this.iterations, this.salt, this.dklen);

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = PBKDF2KeyDerivator(mac)..init(Pbkdf2Parameters(salt, iterations, dklen));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {'c': iterations, 'dklen': dklen, 'prf': 'hmac-sha256', 'salt': bytesToHex(salt)};
  }

  @override
  final String name = 'pbkdf2';
}

class _ScryptKeyDerivator extends _KeyDerivator {
  final int dklen;
  final int n;
  final int r;
  final int p;
  final Uint8List salt;

  _ScryptKeyDerivator(this.dklen, this.n, this.r, this.p, this.salt);

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = Scrypt()..init(ScryptParameters(n, r, p, dklen, salt));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'dklen': dklen,
      'n': n,
      'r': r,
      'p': p,
      'salt': bytesToHex(salt),
    };
  }

  @override
  final String name = 'scrypt';
}

/// Represents a wallet file. Wallets are used to securely store credentials
/// like a private key belonging to an Ethereum address. The private key in a
/// wallet is encrypted with a secret password that needs to be known in order
/// to obtain the private key.
@immutable
class Keystore {
  /// The credentials stored in this wallet file
  final Uint8List privateKey;

  /// The key derivator used to obtain the aes decryption key from the password
  final _KeyDerivator _derivator;

  final Uint8List _password;
  final Uint8List _iv;

  final Uint8List _id;

  const Keystore._(this.privateKey, this._derivator, this._password, this._iv, this._id);

  /// Gets the random uuid assigned to this wallet file
  String get uuid => formatUuid(_id);

  /// Encrypts the private key using the secret specified earlier and returns
  /// a json representation of its data as a v3-wallet file.
  String toJson() {
    final ciphertextBytes = _encryptPrivateKey();

    final map = {
      'crypto': {
        'cipher': 'aes-128-ctr',
        'cipherparams': {'iv': bytesToHex(_iv)},
        'ciphertext': bytesToHex(ciphertextBytes),
        'kdf': _derivator.name,
        'kdfparams': _derivator.encode(),
        'mac': _generateMac(_derivator.deriveKey(_password), ciphertextBytes),
      },
      'id': uuid,
      'version': 3,
    };

    return json.encode(map);
  }

  /// Creates a new wallet wrapping the specified [credentials] by encrypting
  /// the private key with the [password]. The [random] instance, which should
  /// be cryptographically secure, is used to generate encryption keys.
  /// You can configure the parameter N of the scrypt algorithm if you need to.
  /// The default value for [scryptN] is 8192. Be aware that this N must be a
  /// power of two.
  static Keystore createNew(Uint8List credentials, String password, Random random,
      {int scryptN = 8192}) {
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final dartRandom = RandomBridge(random);

    final salt = dartRandom.nextBytes(32);
    final derivator = _ScryptKeyDerivator(32, scryptN, 8, 1, salt);

    final uuid = generateUuidV4();

    final iv = dartRandom.nextBytes(128 ~/ 8);

    var keystore;
    while (keystore == null) {
      try {
        keystore = Keystore._(credentials, derivator, passwordBytes, iv, uuid);
      } catch (e) {}
    }

    return keystore;
  }

  /// Reads and unlocks the wallet denoted in the json string given with the
  /// specified [password]. [encoded] must be the String contents of a valid
  /// v3 Ethereum wallet file.
  static Keystore fromJson(String encoded, String password) {
    /*
      In order to read the wallet and obtain the secret key stored in it, we
      need to do the following:
      1: Key Derivation: Based on the key derivator specified (either pbdkdf2 or
         scryt), we need to use the password to obtain the aes key used to
         decrypt the private key.
      2: Using the obtained aes key and the iv parameter, decrypt the private
         key stored in the wallet.
    */

    final data = json.decode(encoded);

    // Ensure version is 3, only version that we support at the moment
    final version = data['version'];
    if (version != 3) {
      throw ArgumentError.value(
          version,
          'version',
          'Library only supports '
              'version 3 of wallet files at the moment. However, the following value'
              ' has been given:');
    }

    final crypto = data['crypto'] ?? data['Crypto'];

    final kdf = crypto['kdf'] as String;
    _KeyDerivator derivator;

    switch (kdf) {
      case 'pbkdf2':
        final derParams = crypto['kdfparams'] as Map<String, dynamic>;

        if (derParams['prf'] != 'hmac-sha256') {
          throw ArgumentError(
              'Invalid prf supplied with the pdf: was ${derParams["prf"]}, expected hmac-sha256');
        }

        derivator = _PBDKDF2KeyDerivator(derParams['c'] as int,
            Uint8List.fromList(hexToBytes(derParams['salt'] as String)), derParams['dklen'] as int);

        break;
      case 'scrypt':
        final derParams = crypto['kdfparams'] as Map<String, dynamic>;
        derivator = _ScryptKeyDerivator(
            derParams['dklen'] as int,
            derParams['n'] as int,
            derParams['r'] as int,
            derParams['p'] as int,
            Uint8List.fromList(hexToBytes(derParams['salt'] as String)));
        break;
      default:
        throw ArgumentError(
            'Wallet file uses $kdf as key derivation function, which is not supported.');
    }

    // Now that we have the derivator, let's obtain the aes key:
    final encodedPassword = Uint8List.fromList(utf8.encode(password));
    final derivedKey = derivator.deriveKey(encodedPassword);
    final aesKey = Uint8List.fromList(derivedKey.sublist(0, 16));

    final encryptedPrivateKey = hexToBytes(crypto['ciphertext'] as String);

    //Validate the derived key with the mac provided
    final derivedMac = _generateMac(derivedKey, encryptedPrivateKey);
    if (derivedMac != crypto['mac'])
      throw ArgumentError(
          'Could not unlock wallet file. You either supplied the wrong password or the file is corrupted');

    // We only support this mode at the moment
    if (crypto['cipher'] != 'aes-128-ctr') {
      throw ArgumentError(
          'Wallet file uses ${crypto["cipher"]} as cipher, but only aes-128-ctr is supported.');
    }
    final iv = Uint8List.fromList(hexToBytes(crypto['cipherparams']['iv'] as String));

    // Decrypt the private key

    final aes = _initCipher(false, aesKey, iv);

    final credentials = aes.process(Uint8List.fromList(encryptedPrivateKey));

    final id = parseUuid(data['id'] as String);

    return Keystore._(credentials, derivator, encodedPassword, iv, id);
  }

  static String _generateMac(List<int> dk, List<int> ciphertext) {
    final macBody = <int>[]..addAll(dk.sublist(16, 32))..addAll(ciphertext);

    return bytesToHex(keccak256(uint8ListFromList(macBody)));
  }

  static CTRStreamCipher _initCipher(bool forEncryption, Uint8List key, Uint8List iv) {
    return CTRStreamCipher(AESFastEngine())..init(false, ParametersWithIV(KeyParameter(key), iv));
  }

  List<int> _encryptPrivateKey() {
    final derived = _derivator.deriveKey(_password);
    final aesKey = Uint8List.view(derived.buffer, 0, 16);

    final aes = _initCipher(true, aesKey, _iv);
    return aes.process(privateKey);
  }
}
