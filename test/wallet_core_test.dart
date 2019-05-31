import 'dart:convert';

import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckbcore/base/bean/balance_bean.dart';
import 'package:ckbcore/base/bean/receiver_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/config/keystore_config.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:test/test.dart';

main() async {
  test('test', () async {
    MyWalletCore walletCore = MyWalletCore('test/store/store', 'http://localhost:8114');
    // await walletCore.init('123456');
    String mnemonic = 'afford wisdom bus dutch more acid rent treat alcohol pretty thought usual';
    // await walletCore.create('123456');
    await walletCore.walletFromImport(mnemonic, 'password');
    try {
      await walletCore.sendCapacity(
          [ReceiverBean('ckt1q9gry5zgxmpjnmtrp4kww5r39frh2sm89tdt2l6v234ygf', 6000000000)],
          Network.TestNet,
          "123456");
    } catch (e) {
      print(e.toString());
    }
    // walletCore.updateCurrentIndexCells();
  });
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
    var config = KeystoreConfig('', privateKey);
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
