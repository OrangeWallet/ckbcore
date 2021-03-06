import 'dart:convert';

import 'package:ckb_sdk/ckb_address.dart' show CKBNetwork;
import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/ckbcore_bean.dart';
import 'package:ckbcore/src/utils/log.dart';
import 'package:convert/convert.dart';

main() async {
  MyWalletCore walletCore = MyWalletCore('test/store/store', 'http://192.168.2.78:8114');
  String privateKey = "e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3";
  try {
    walletCore.clearStore();
    await walletCore.importWallet(publicKeyFromPrivate(hex.decode(privateKey)));
    walletCore.startSync();
  } catch (e) {
    print(e.toString());
  }
}

class MyWalletCore extends WalletCore {
  String json =
      '{"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"a65f5db5dd9128db77d59e91bed59d50"},"ciphertext":"7d52cd814e16d5ef34a68b7ce4aff4ca693f2d6c5404e74688bc8d4368f9578d","kdf":"scrypt","kdfparams":{"dklen":32,"n":8192,"r":8,"p":1,"salt":"3142fb3eba6da4e0a644622e1aef215b11d4672512ec890d73d00c63ae1ef919"},"mac":"6459630ceb4124d8de0dbec35f78bd1b1b98f87a70c18fa052a8867e9b5b715b"},"id":"88d9c86c-a9cf-43f7-a556-e7226d5695d1","version":3}';

  MyWalletCore(String storePath, String nodeUrl)
      : super(storePath, nodeUrl, CKBNetwork.Testnet, true);

  @override
  syncProcess(double processing) async {
    Log.log(processing);
  }

  @override
  blockChanged(ThinBlock thinBlock) {
    Log.log(jsonEncode(balanceBean));
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
