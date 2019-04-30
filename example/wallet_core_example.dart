import 'dart:convert';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';

main() async {
  Uint8List privateKey =
      intToBytes(toBigInt(remove0x('e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3')));
  MyWalletCore walletCore = MyWalletCore(HDCoreConfig(privateKey, 1, 1), 'test/store/store');
  await walletCore.updateCurrentIndexCells();
  print(jsonEncode(walletCore.cellsResultBean.cells.length));
}

class MyWalletCore extends WalletCore {
  MyWalletCore(HDCoreConfig hdCoreConfig, String storePath) : super(hdCoreConfig, storePath);

  @override
  blockChanged() {
    print('blcok synced to ${this.cellsResultBean.syncedBlockNumber}');
  }

  @override
  cellsChanged() {
    print('cells size is ${this.cellsResultBean.cells.length}');
  }
}
