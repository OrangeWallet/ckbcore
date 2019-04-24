import 'package:ckb_sdk/ckb-types/item/out_point.dart';
import 'package:ckb_sdk/ckb-types/item/script.dart';

class CellBean {
  String capacity;
  String data;
  Script lock;
  Script type;
  OutPoint outPoint;
  String status;
  String lockHash;
  String hdPath;

  CellBean(this.capacity, this.data, this.lock, this.type, this.outPoint, this.status, this.lockHash, this.hdPath);

  factory CellBean.fromJson(Map<String, dynamic> json) => CellBean(
        json['capacity'] as String,
        json['data'] as String,
        json['lock'] == null ? null : Script.fromJson(json['lock']),
        json['type'] == null ? null : Script.fromJson(json['type']),
        json['outPoint'] == null ? null : OutPoint.fromJson(json['outPoint']),
        json['status'] as String,
        json['lockHash'] as String,
        json['hdPath'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'capacity': capacity,
        'data': data,
        'lock': lock,
        'type': type,
        'outPoint': outPoint,
        'status': status,
        'lockHash': lockHash,
        'hdPath': hdPath,
      };
}
