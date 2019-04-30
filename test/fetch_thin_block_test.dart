import 'dart:convert';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/sync/fetch_thin_block.dart';
import 'package:test/test.dart';

main() {
  test('fetch thin block', () async {
    Uint8List privateKey =
        intToBytes(toBigInt(remove0x('e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3')));
    HDCore hdCore = HDCore(HDCoreConfig(privateKey, 0, 0));
    try {
      var result = await fetchBlockToCheckCell(FetchBlockToCheckParam(hdCore, 10000));
      print(jsonEncode(result));
    } catch (e) {
      var json = jsonDecode(e);
      print(e);
    }
  });
}
