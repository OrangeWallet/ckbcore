import 'dart:convert';

import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckbcore/base/bean/balance_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/ckbcore.dart';

main() async {
  MyWalletCore walletCore = MyWalletCore('test/store/store', 'http://47.111.175.189:8121');
//  await walletCore.init('123456');
  String mnemonic = 'afford wisdom bus dutch more acid rent treat alcohol pretty thought usual';
  // String address = 'ckt1q9gry5zgflanvykpepaad4vt9vd5z3vk9p3seeut5en294';
  // await walletCore.create('123456');
  await walletCore.import(mnemonic, 'password');
//  Future.delayed(Duration(seconds: 5), () async {
//    try {
//      await walletCore.sendCapacity(
//          [ReceiverBean('ckt1q9gry5zgxmpjnmtrp4kww5r39frh2sm89tdt2l6v234ygf', 6000000000)],
//          Network.TestNet);
//    } catch (e) {
//      print(e.toString());
//    }
//  });
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
    var config = HDCoreConfig('', privateKey, 0, 0);
    return jsonEncode(config);
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
