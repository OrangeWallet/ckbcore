import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/isolate_result/isolate_result_base.dart';

class CellsIsolateResultBean extends IsolateResultBase<List<CellBean>> {
  CellsIsolateResultBean(status, errorMessage, result) : super(status, errorMessage, result);

  factory CellsIsolateResultBean.fromJson(Map<String, dynamic> json) => CellsIsolateResultBean(
        json['status'] as bool,
        json['errorMessage'] as String,
        (json['result'] as List)?.map((e) => e == null ? null : CellBean.fromJson(e as Map<String, dynamic>))?.toList(),
      );

  factory CellsIsolateResultBean.fromSuccess(List<CellBean> result) => CellsIsolateResultBean(
        true,
        '',
        result,
      );

  factory CellsIsolateResultBean.fromFail(String errorMessage) => CellsIsolateResultBean(
        false,
        errorMessage,
        [],
      );
}
