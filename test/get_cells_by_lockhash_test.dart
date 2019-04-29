import 'dart:typed_data';
import 'dart:convert';

import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_by_lockhash.dart';
import 'package:test/test.dart';

main() {
  CKBApiClient ckbApiClient = CKBApiClient(nodeUrl: 'http://47.111.175.189:8121');
  Uint8List privateKey =
      intToBytes(toBigInt(remove0x('e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3')));
  String lockHash = '0x266cec97cbede2cfbce73666f08deed9560bdf7841a7a5a51b3a3f09da249e21';
  HDCore hdCore = HDCore(HDCoreConfig(privateKey, 0, 0));
  test('get cells by lockHash', () async {
    var targetBlockNumber = await ckbApiClient.getTipBlockNumber();
    print(targetBlockNumber);
    List<CellBean> cells = await getCellByLockHash(GetCellByLockHashParams(0, 100, hdCore.unusedChangeWallet));
    print(jsonEncode(cells));
  });

  test('get tip block number', () async {
    var targetBlockNumber = await ckbApiClient.getTipBlockNumber();
    print(targetBlockNumber);
  });
}
