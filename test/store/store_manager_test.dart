import 'dart:convert';

import 'package:ckb_sdk/ckb_types.dart';
import 'package:ckbcore/src/bean/cell_bean.dart';
import 'package:ckbcore/src/bean/cells_result_bean.dart';
import 'package:ckbcore/src/store/store_manager.dart';
import 'package:ckbcore/src/utils/log.dart';
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
