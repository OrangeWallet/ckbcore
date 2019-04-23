import 'dart:typed_data';

import 'package:ckbcore/src/base/bean/hd_index_wallet.dart';
import 'package:ckbcore/src/base/bean/utxo_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/utils/searchUtxoUtils.dart' as SearchUtxoUtils;

class WalletCore {
  final Uint8List seed;
  HDCore _hdCore;

  WalletCore._(this.seed, int receiveIndex, int changeIndex) {
    _hdCore = HDCore(seed, receiveIndex, changeIndex);
  }

  static Future<WalletCore> fromImport(Uint8List seed) async {
    HDCore hdCore = HDCore(seed, -1, -1);
    return WalletCore._(seed, hdCore.unusedReceiveWallet.index,
        hdCore.unusedChangeWallet.index);
  }

  static fromCreate(Uint8List seed) {
    return WalletCore._(seed, 0, 0);
  }

  static fromStore(Uint8List seed, int receive, int change) {
    return WalletCore._(seed, receive, receive);
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  //Searching all Utxos.Include index before current receive index and change index
  Future<List<UtxoBean>> searchAllUtxos() async {
    return await SearchUtxoUtils.searchAll(_hdCore);
  }

  //Searching current index Utxos
  Future<List<UtxoBean>> searchCurrentUtxos() async {
    return await SearchUtxoUtils.searchCurrentIndexUtxos(_hdCore);
  }
}
