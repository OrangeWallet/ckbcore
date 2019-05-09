import 'dart:convert';

import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/base/utils/get_cells_utils/get_unspent_cells_by_lockhash.dart';
import 'package:test/test.dart';

main() {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';
  // String lockHash = '0x266cec97cbede2cfbce73666f08deed9560bdf7841a7a5a51b3a3f09da249e21';
  HDCore hdCore = HDCore(HDCoreConfig('', privateKey, 0, 0));
  test('get cells by lockHash', () async {
    var targetBlockNumber = await ApiClient.getTipBlockNumber();
    Log.log(targetBlockNumber);
    List<CellBean> cells =
        await getCellByLockHash(GetCellByLockHashParams(0, 100, hdCore.unusedReceiveWallet), (start, target, current) {
      print(target);
      print(current);
    });
    Log.log(jsonEncode(cells));
  });

  test('get tip block number', () async {
    var targetBlockNumber = await ApiClient.getTipBlockNumber();
    Log.log(targetBlockNumber);
  });
}
