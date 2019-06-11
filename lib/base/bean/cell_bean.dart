import 'package:ckb_sdk/ckb-types/item/cell_output.dart';
import 'package:ckb_sdk/ckb-types/item/out_point.dart';

class CellBean {
  CellOutput cellOutput;
  String status;
  String lockHash;
  OutPoint outPoint;

  CellBean(this.cellOutput, this.status, this.lockHash, this.outPoint);

  factory CellBean.fromJson(Map<String, dynamic> json) => CellBean(
        json['cellOutput'] == null ? null : CellOutput.fromJson(json['cellOutput']),
        json['status'] as String,
        json['lockHash'] as String,
        json['outPoint'] == null ? null : OutPoint.fromJson(json['outPoint']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cellOutput': cellOutput,
        'status': status,
        'lockHash': lockHash,
        'outPoint': outPoint,
      };
}
