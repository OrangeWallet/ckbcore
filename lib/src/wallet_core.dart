import 'dart:typed_data';

import 'package:orange_wallet_core/src/base/bean/utxo_bean.dart';
import 'package:orange_wallet_core/src/base/hd_core/hd_core.dart';
import 'package:orange_wallet_core/src/base/utils/searchUtxoUtils.dart' as SearchUtxoUtils;

class WalletCore {
  final Uint8List seed;
  HDCore _hdCore;

  WalletCore._(this.seed, int receiveIndex, int changeIndex) {
    _hdCore = HDCore(seed, receiveIndex, changeIndex);
  }

  static Future<WalletCore> fromImport(Uint8List seed) async {
    HDCore hdCore = HDCore(seed, 0, 0);
    hdCore.getUnusedChangePrivateKey();
    return WalletCore._(seed, hdCore.unusedReceiveIndex, hdCore.unusedChangeIndex);
  }

  static fromCreate(Uint8List seed) {
    return WalletCore._(seed, 0, 0);
  }

  static fromStore(Uint8List seed, int receive, int change) {
    return WalletCore._(seed, receive, receive);
  }

  int get unusedReceiveIndex => _hdCore.unusedReceiveIndex;

  int get unusedChangeIndex => _hdCore.unusedChangeIndex;

  //Searching all Utxos.Include index before current receive index and change index
  Future<List<UtxoBean>> searchAllUtxos() async {
    return await SearchUtxoUtils.searchAll(_hdCore);
  }

  //Searching current index Utxos
  Future<List<UtxoBean>> searchCurrentUtxos() async {
    return await SearchUtxoUtils.searchCurrentIndexUtxos(_hdCore);
  }
}
