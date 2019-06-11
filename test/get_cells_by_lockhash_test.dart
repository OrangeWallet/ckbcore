import 'dart:convert';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/credential.dart';
import 'package:ckbcore/base/core/my_wallet.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells_by_lockhash.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:test/test.dart';

main() {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';
  test('get cells by lockHash', () async {
    var targetBlockNumber = await CKBApiClient(Constant.NodeUrl).getTipBlockNumber();
    Log.log(targetBlockNumber);
    List<CellBean> cells = await getCellByLockHash(
        GetCellByLockHashParams(
            0, 100, MyWallet(Credential.fromPrivateKeyHex(privateKey).publicKey)),
        CKBApiClient(Constant.NodeUrl), (start, target, current) {
      print(target);
      print(current);
    });
    Log.log(jsonEncode(cells));
  });

  test('get tip block number', () async {
    var targetBlockNumber = await CKBApiClient(Constant.NodeUrl).getTipBlockNumber();
    Log.log(targetBlockNumber);
  });
}
