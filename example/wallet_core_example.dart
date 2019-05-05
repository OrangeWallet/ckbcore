import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'dart:convert';

import 'package:ckbcore/src/base/utils/log.dart';

main() async {
  MyWalletCore walletCore = MyWalletCore('test/store/store', 'http://192.168.2.78:8114');
  await walletCore.init('123456');
  // String mnemonic = 'afford wisdom bus dutch more acid rent treat alcohol pretty thought usual';
  // await walletCore.create('', '123456');
  Log.log(walletCore.unusedChangeWallet.lockScript.scriptHash);
  walletCore.updateCurrentIndexCells();
}

class MyWalletCore extends WalletCore {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';

  MyWalletCore(String storePath, String nodeUrl) : super(storePath, nodeUrl);

  @override
  blockChanged() {
    Log.log('blcok synced to ${this.cellsResultBean.syncedBlockNumber}');
  }

  @override
  cellsChanged() {
    Log.log('cells size is ${this.cellsResultBean.cells.length}');
  }

  @override
  createStep(int step) {
    Log.log(step);
  }

  @override
  Future<String> readWallet(String password) async {
    var config = HDCoreConfig('', privateKey, 0, 0);
    return jsonEncode(config);
  }

  @override
  writeWallet(String wallet, String password) {}

  @override
  syncedFinished() {
    Log.log('syncedFinished');
  }

  @override
  createFinished(bool isCreate) {
    return null;
  }
}
