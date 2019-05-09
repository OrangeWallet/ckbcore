import 'dart:convert';

import 'package:ckbcore/base/bean/balance_bean.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/utils/log.dart';

main() async {
  MyWalletCore walletCore = MyWalletCore('test/store/store', 'http://192.168.2.78:8114');
  // await walletCore.init('123456');
  // String mnemonic = 'afford wisdom bus dutch more acid rent treat alcohol pretty thought usual';
  await walletCore.create('123456');
  // await walletCore.import(mnemonic, 'password');
  // Log.log(walletCore.unusedReceiveWallet.lockScript.scriptHash);
  // await walletCore.clearStore();
  // Log.log('Clear finished');
}

class MyWalletCore extends WalletCore {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';

  MyWalletCore(String storePath, String nodeUrl) : super(storePath, nodeUrl, true);

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
  syncProcess(double processing) {
    Log.log(processing);
  }

  @override
  exception(Exception e) {
    Log.log(e.toString());
  }

  @override
  blockChanged(ThinBlock thinBlock) {
    // Log.log(jsonEncode(thinBlock));
    // Log.log('blcok synced to ${thinBlock.thinHeader.number}');
  }

  @override
  cellsChanged(BalanceBean balance) {
    Log.log(jsonEncode(balance));
  }
}
