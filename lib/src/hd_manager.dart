import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;

class PathManager {
  bip32.BIP32 _node;
  final int _coinType;
  final int _purpose = 44;
  final _external = 0;
  final _internal = 1;
  int _account;

  PathManager(Uint8List seed, this._coinType, {int account: 0}) {
    _node = bip32.BIP32.fromSeed(seed);
  }

  set account(int account) {
    _account = account;
  }

  int get account => _account;

  getExternalSeed(int index) {
    return _node.derivePath("m/$_purpose'/$_coinType'/$_account'/$_external/$index");
  }

  getInternalSeed(int index) {
    return _node.derivePath("m/$_purpose'/$_coinType'/$_account'/$_internal/$index");
  }
}
