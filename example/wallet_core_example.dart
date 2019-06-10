import 'dart:convert';

import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckbcore/base/bean/balance_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/ckbcore.dart';

main() async {
  MyWalletCore walletCore = MyWalletCore('test/store/store', 'http://localhost:8114');
//  await walletCore.init('123456');
  // await walletCore.create('123456');
  await walletCore.walletFromPrivateKey(
      "e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3", "123");
  walletCore.updateCurrentIndexCells();
}

class MyWalletCore extends WalletCore {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';

  MyWalletCore(String storePath, String nodeUrl) : super(storePath, nodeUrl, Network.TestNet, true);

  @override
  createStep(int step) {
    Log.log(step);
  }

  @override
  Future<String> readWallet(String password) async {
    return privateKey;
  }

  @override
  writeWallet(String wallet, String password) {}

  @override
  syncProcess(double processing) async {
    Log.log(processing);
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

  @override
  syncException(Exception e) {
    print(e.toString());
  }
}
