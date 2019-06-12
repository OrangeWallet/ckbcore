import 'package:ckb_sdk/ckb_types.dart' show Block;
import 'package:ckbcore/base/bean/thin_transaction.dart';

class ThinBlock {
  List<ThinTransaction> thinTrans;
  ThinHeader thinHeader;

  ThinBlock(this.thinHeader, this.thinTrans);

  factory ThinBlock.fromBlock(Block block) => ThinBlock(
        ThinHeader(block.header.hash, block.header.number, block.header.timestamp),
        [],
      );

  factory ThinBlock.fromJson(Map<String, dynamic> json) => ThinBlock(
        json['thinHeader'] == null ? null : ThinHeader.fromJson(json['thinHeader']),
        (json['transactions'] as List)
            ?.map((e) => e == null ? null : ThinTransaction.fromJson(e as Map<String, dynamic>))
            ?.toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'thinHeader': thinHeader,
        'thinTrans': thinTrans,
      };
}

class ThinHeader {
  String hash;
  String number;
  String timestamp;

  ThinHeader(this.hash, this.number, this.timestamp);

  factory ThinHeader.fromJson(Map<String, dynamic> json) => ThinHeader(
        json['hash'] as String,
        json['number'] as String,
        json['timestamp'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hash': hash,
        'number': number,
        'timestamp': timestamp,
      };
}
