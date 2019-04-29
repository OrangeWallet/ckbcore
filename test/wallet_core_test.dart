import 'dart:typed_data';
import 'dart:convert';

import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/interface/wallet_core_interface.dart';
import 'package:ckbcore/src/wallet_core.dart';
import 'package:test/test.dart';

main() {
  Uint8List privateKey =
      intToBytes(toBigInt(remove0x('e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3')));
  test('from create', () async {
    WalletCore walletCore = WalletCore(HDCoreConfig(privateKey, 0, 0), MyWalletCoreInterface(), 'test/store/store');
    expect(walletCore.unusedReceiveWallet.getAddress(Network.TestNet),
        'ckt1q9gry5zg4vcktax5mn6tqeys5vteev8up9lp9zuyfhzrwl');
    expect(walletCore.unusedChangeWallet.getAddress(Network.TestNet),
        'ckt1q9gry5zgsnedfvtyw9yak2heyhjg4qgyud076enk7g6d82');
    await walletCore.getCurrentIndexCells();
    print(jsonEncode(walletCore.cellsResultBean));
  });

  test('from store', () async {
    WalletCore walletCore = WalletCore(HDCoreConfig(privateKey, 1, 1), MyWalletCoreInterface(), 'test/store/store');
    expect(walletCore.unusedReceiveWallet.getAddress(Network.TestNet),
        'ckt1q9gry5zgutwq4r864ypfu0pethxrn50q8gyc6qayzqh758');
    expect(walletCore.unusedChangeWallet.getAddress(Network.TestNet),
        'ckt1q9gry5zgss8plvxyt37gq3tmfwpj5lrgj8gernusf0x8d6');
    await walletCore.getCurrentIndexCells();
    print(jsonEncode(walletCore.cellsResultBean));
  });
}

class MyWalletCoreInterface extends WalletCoreInterface {
  @override
  cellsChanged() {
    print('changed');
  }
}
