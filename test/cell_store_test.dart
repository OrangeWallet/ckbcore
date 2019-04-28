import 'dart:convert';

import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/store/cell_store.dart';
import 'package:test/test.dart';

main() {
  CellsStore cellsStore = CellsStore('test/store/');
  test('cell store', () async {
    CellsResultBean cells = await cellsStore.getFromStore();
    print(jsonEncode(cells));
  });

  test('cell write', () async {
    CellBean bean = CellBean(CellOutput("1", "1", Script('1', []), Script('1', [])), '1', '1', OutPoint('1', 1), '1');
    var cellResultBean = CellsResultBean([bean], '1');
    cellsStore.saveToStore(cellResultBean);
  });
}
