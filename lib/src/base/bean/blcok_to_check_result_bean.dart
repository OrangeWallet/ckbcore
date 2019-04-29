import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/thin_block.dart';

class BlockToCheckResultBean {
  final List<CellBean> spendCells;
  final List<CellBean> newCells;
  final ThinBlock thinBlock;

  BlockToCheckResultBean(this.spendCells, this.newCells, this.thinBlock);

  factory BlockToCheckResultBean.fromJson(Map<String, dynamic> json) => BlockToCheckResultBean(
        (json['spendCells'] as List)
            ?.map((e) => e == null ? null : CellBean.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        (json['newCells'] as List)
            ?.map((e) => e == null ? null : CellBean.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        (json['thinBlock']) == null ? null : ThinBlock.fromJson(json['thinBlock']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'spendCells': spendCells,
        'newCells': newCells,
        'thinBlock': thinBlock,
      };
}
