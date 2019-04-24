import 'dart:typed_data';

import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/utils/searchUtxoUtils.dart' as SearchUtxoUtils;

class WalletCore {
  final Uint8List seed;
  HDCore _hdCore;

  WalletCore._(this.seed, int receiveIndex, int changeIndex) {
    _hdCore = HDCore(seed, receiveIndex, changeIndex);
  }

  static WalletCore fromImport(Uint8List seed) {
    return WalletCore._(seed, -1, -1);
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
  Future<List<CellBean>> searchAllCells() async {
    return await SearchUtxoUtils.searchAll(_hdCore);
  }

  //Searching current index Utxos
  Future<List<CellBean>> searchCurrentCells() async {
    return await SearchUtxoUtils.searchCurrentIndexCells(_hdCore);
  }
}
