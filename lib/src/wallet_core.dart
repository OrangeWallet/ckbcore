import 'dart:typed_data';

import 'package:orange_wallet_core/src/base/hd_core/hd_core.dart';

class WalletCore extends HDCore {
  WalletCore(
      Uint8List seed, int firstUnusedReceiveIndex, int firstUnusedChangeIndex)
      : super(seed, firstUnusedReceiveIndex, firstUnusedChangeIndex);

  Future searchNewWallet() async {
    await fetchAllTransactions();
  }

  @override
  Future<int> checkTransaction(Uint8List privateKey) {
    return null;
  }

  @override
  Future<BigInt> checkUnspentCell(int index, Uint8List privateKey) {
    return null;
  }
}
