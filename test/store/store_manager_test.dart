import 'dart:convert';

import 'package:ckb_sdk/ckb-types/res_export.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/store/store_manager.dart';
import 'package:test/test.dart';

main() {
  StoreManager storeManager = StoreManager('test/store/store');

  test('syncBlockNumber', () async {
    await storeManager.syncBlockNumber('1000');
    CellsResultBean cellsResultBean = await storeManager.getSyncedCells();
    expect('1000', cellsResultBean.syncedBlockNumber);
  });

  test('syncCells', () async {
    CellBean bean1 = CellBean(CellOutput("1", "1", Script('1', []), Script('1', [])), '1', '1', OutPoint('1', 1), '1');
    CellBean bean2 = CellBean(CellOutput("2", "2", Script('2', []), Script('2', [])), '2', '2', OutPoint('2', 2), '2');
    await storeManager.syncCells(CellsResultBean([bean1, bean2], '2000'));
  });

  test('get', () async {
    var reslut = await storeManager.getSyncedCells();
    print(jsonEncode(reslut));
  });
}
