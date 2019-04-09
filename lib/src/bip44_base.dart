import 'dart:typed_data';
import 'package:hd_account_discovery/src/hd_manager.dart';

class Bip44 {
  PathManager _pathManager;

  Bip44(Uint8List seed, int coinType, {int account: 0}) {
    _pathManager = PathManager(seed, coinType, account: account);
  }

  PathManager get addresses => _pathManager;
}
