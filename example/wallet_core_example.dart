import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'dart:convert';

main() async {
  MyWalletCore walletCore = MyWalletCore('test/store/store');
  // await walletCore.init();
  // String mnemonic = 'afford wisdom bus dutch more acid rent treat alcohol pretty thought usual';
  await walletCore.create('', '123456');
  print(walletCore.unusedChangeWallet.lockScript.scriptHash);
  walletCore.updateCurrentIndexCells();
}

class MyWalletCore extends WalletCore {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';

  MyWalletCore(String storePath) : super(storePath);

  @override
  blockChanged() {
    print('blcok synced to ${this.cellsResultBean.syncedBlockNumber}');
  }

  @override
  cellsChanged() {
    print('cells size is ${this.cellsResultBean.cells.length}');
  }

  @override
  createStep(int step) {
    print(step);
  }

  @override
  Future<String> getWallet(String password) async {
    var config = HDCoreConfig('', privateKey, 0, 0);
    return jsonEncode(config);
  }

  @override
  storeWallet(String wallet, String password) {}

  @override
  syncedFinished() {
    print('syncedFinished');
  }
}
