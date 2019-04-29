import 'dart:convert';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/ckbcore.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';

main() async {
  Uint8List privateKey =
      intToBytes(toBigInt(remove0x('e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3')));
  WalletCore walletCore = WalletCore(HDCoreConfig(privateKey, 1, 1), 'test/store/store');
  await walletCore.getCurrentIndexCells();
  print(jsonEncode(walletCore.cellsResultBean));
}
