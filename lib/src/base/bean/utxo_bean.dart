import 'package:ckb_sdk/ckb-types/item/cell.dart';

class UtxoBean {
  Cell cell;
  String path;

  UtxoBean(this.cell, this.path);

  factory UtxoBean.fromJson(Map<String, dynamic> json) => UtxoBean(
        json['cell'] == null ? null : Cell.fromJson(json['cell'] as Map<String, dynamic>),
        json['path'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cell': cell,
        'path': path,
      };
}
