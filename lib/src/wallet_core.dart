import 'dart:typed_data';

import 'package:orange_wallet_core/src/base/hd_core/hd_core.dart';

class WalletCore {
  final Uint8List seed;
  Uint8List receive;
  Uint8List change;
  HDCore _hdCore;

  WalletCore._(this.seed, int receiveIndex, int changeIndex) {
    _hdCore = HDCore(seed, receiveIndex, changeIndex);
    receive = _hdCore.getUnusedReceive();
    change = _hdCore.getUnusedChange();
  }

  static Future<WalletCore> fromImport(Uint8List seed) async {
    HDCore hdCore = HDCore(seed, 0, 0);
    hdCore.getUnusedChange();
    return WalletCore._(seed, hdCore.unusedReceiveIndex, hdCore.unusedChangeIndex);
  }

  static fromCreate(Uint8List seed) {
    return WalletCore._(seed, 0, 0);
  }

  static fromStore(Uint8List seed, int receive, int change) {
    return WalletCore._(seed, receive, receive);
  }
}
