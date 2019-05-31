import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';
  test('core', () {
    HDCore hdCore = HDCore(hex.decode(privateKey));
    Log.log(hdCore.unusedReceiveWallet.lockScript.scriptHash);
    expect(hdCore.unusedReceiveWallet.getAddress(Network.TestNet),
        'ckt1q9gry5zg4vcktax5mn6tqeys5vteev8up9lp9zuyfhzrwl');
    expect(hdCore.unusedChangeWallet.getAddress(Network.TestNet),
        'ckt1q9gry5zgsnedfvtyw9yak2heyhjg4qgyud076enk7g6d82');
  });
}
