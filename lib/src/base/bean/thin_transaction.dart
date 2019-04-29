import 'package:ckb_sdk/ckb-types/item/script.dart';

class ThinTransaction {
  String hash;
  List<ThinCell> cellsInputs;
  List<ThinCell> cellsOutputs;

  ThinTransaction(this.hash, this.cellsInputs, this.cellsOutputs);

  factory ThinTransaction.fromJson(Map<String, dynamic> json) => ThinTransaction(
        json['hash'] as String,
        (json['cellsInput'] as List)
            ?.map((e) => e == null ? null : ThinCell.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        (json['cellsOutput'] as List)
            ?.map((e) => e == null ? null : ThinCell.fromJson(e as Map<String, dynamic>))
            ?.toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hash': hash,
        'cellsInputs': cellsInputs,
        'cellsOutputs': cellsOutputs,
      };
}

class ThinCell {
  String capacity;
  Script lock;

  ThinCell(this.capacity, this.lock);

  factory ThinCell.fromJson(Map<String, dynamic> json) => ThinCell(
        json['capacity'] as String,
        json['lock'] == null ? null : Script.fromJson(json['lock'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'capacity': capacity,
        'lock': lock.toJson(),
      };
}
