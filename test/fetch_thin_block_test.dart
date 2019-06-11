import 'dart:convert';

import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/my_wallet.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_thin_block.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  test('fetch thin block', () async {
    String privateKey = '3e58f0c69c224bbf90627cd1aabe09c3f8582b1f89a978274af625f54d588521';
    var myWallet = MyWallet(hex.decode(privateKey));
    var result = await testFetchBlockToCheckCell(
        FetchBlockToCheckParam(myWallet, 8869, CKBApiClient(Constant.NodeUrl)));
    Log.log(jsonEncode(result));
  });
}
