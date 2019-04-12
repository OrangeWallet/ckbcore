import 'dart:typed_data';

import 'package:orange_wallet_core/src/base/core_base.dart';

class WalletCore extends BaseCore {
  WalletCore(Uint8List seed, {firstUnusedChangeIndex: 0, firstUnusedReceiveIndex: 0})
      : super(seed, firstUnusedChangeIndex, firstUnusedReceiveIndex);

  @override
  Future<int> checkTransaction(Uint8List privateKey) {
    // TODO: implement checkTransaction
    return null;
  }

  @override
  Future<BigInt> checkUnspentCell(Uint8List privateKey) {
    // TODO: implement checkUnspentCell
    return null;
  }
}
