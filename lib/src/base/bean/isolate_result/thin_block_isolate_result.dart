import 'package:ckbcore/src/base/bean/isolate_result/isolate_result_base.dart';
import 'package:ckbcore/src/base/bean/thin_bolck_with_cells.dart';

class ThinBlockIsolateResultBean extends IsolateResultBase<ThinBlockWithCellsBean> {
  ThinBlockIsolateResultBean(status, errorMessage, result) : super(status, errorMessage, result);

  factory ThinBlockIsolateResultBean.fromJson(Map<String, dynamic> json) => ThinBlockIsolateResultBean(
        json['status'] as bool,
        json['errorMessage'] as String,
        json['result'] == null ? null : ThinBlockWithCellsBean.fromJson(json['result']),
      );

  factory ThinBlockIsolateResultBean.fromSuccess(ThinBlockWithCellsBean result) => ThinBlockIsolateResultBean(
        true,
        '',
        result,
      );

  factory ThinBlockIsolateResultBean.fromFail(String errorMessage) => ThinBlockIsolateResultBean(
        false,
        errorMessage,
        null,
      );
}
