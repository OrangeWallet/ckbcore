import 'dart:convert';

import 'package:ckb_sdk/ckb-types/item/cell_out_point.dart';
import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/store/store_manager.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:test/test.dart';

main() {
  StoreManager storeManager = StoreManager('test/store/store');

  test('syncBlockNumber', () async {
    await storeManager.syncBlockNumber('1000');
    CellsResultBean cellsResultBean = await storeManager.getSyncedCells();
    expect('1000', cellsResultBean.syncedBlockNumber);
  });

  test('syncCells', () async {
    CellBean bean1 = CellBean(CellOutput("1", "1", Script('1', []), Script('1', [])), '1', '1',
        OutPoint('1', CellOutPoint('1', '1')));
    CellBean bean2 = CellBean(CellOutput("2", "2", Script('2', []), Script('2', [])), '2', '2',
        OutPoint('2', CellOutPoint('2', '2')));
    await storeManager.syncCells(CellsResultBean([bean1, bean2], '2000'));
  });

  test('get', () async {
    var reslut = await storeManager.getSyncedCells();
    Log.log(jsonEncode(reslut));
  });

  test('get cells length', () async {
    var reslut = await storeManager.getSyncedCells();
    Log.log(reslut.cells.length);
  });

  test('delete all', () async {
    await storeManager.clearAll();
  });
}
