import 'dart:convert';

import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';
import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/store/cell_store.dart';
import 'package:test/test.dart';

main() {
  CellsStore cellsStore = CellsStore('test/store/store');
  test('cell store', () async {
    List<CellBean> cells = await cellsStore.readFromStore();
    print(jsonEncode(cells));
  });

  test('cell write', () async {
    CellBean bean1 = CellBean(CellOutput("1", "1", Script('1', []), Script('1', [])), '1', '1', OutPoint('1', 1), '1');
    CellBean bean2 = CellBean(CellOutput("2", "2", Script('2', []), Script('2', [])), '2', '2', OutPoint('2', 2), '2');
    cellsStore.saveToStore([bean1, bean2]);
  });
}