import 'dart:convert';

import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_thin_block.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:test/test.dart';

main() {
  test('fetch thin block', () async {
    String privateKey = '3e58f0c69c224bbf90627cd1aabe09c3f8582b1f89a978274af625f54d588521';
    HDCore hdCore = HDCore(HDCoreConfig('', privateKey, 0, 0));
    try {
      var result = await fetchBlockToCheckCell(
          FetchBlockToCheckParam(hdCore.unusedReceiveWallet, 8869, CKBApiClient(NodeUrl)));
      Log.log(jsonEncode(result));
    } catch (e) {
      Log.log(e.toString());
    }
  });
}
