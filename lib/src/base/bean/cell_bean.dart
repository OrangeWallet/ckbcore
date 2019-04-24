import 'package:ckb_sdk/ckb-types/item/cell.dart';

class CellBean {
  Cell cell;
  String path;

  CellBean(this.cell, this.path);

  factory CellBean.fromJson(Map<String, dynamic> json) => CellBean(
        json['cell'] == null ? null : Cell.fromJson(json['cell'] as Map<String, dynamic>),
        json['path'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cell': cell,
        'path': path,
      };
}
