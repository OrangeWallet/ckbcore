import 'package:ckbcore/src/base/bean/cell_bean.dart';

class CellsResultBean {
  List<CellBean> cells;
  String syncedBlockNumber;

  CellsResultBean(this.cells, this.syncedBlockNumber);

  factory CellsResultBean.fromJson(Map<String, dynamic> json) => CellsResultBean(
        (json['cells'] as List).map((e) => CellBean.fromJson(e as Map<String, dynamic>)).toList(),
        json['syncedBlockNumber'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cells': cells,
        'syncedBlockNumber': syncedBlockNumber,
      };
}
