import 'package:ckbcore/base/bean/isolate_result/isolate_result_base.dart';
import 'package:ckbcore/base/bean/thin_bolck_with_cells.dart';

class ThinBlockIsolateResultBean extends IsolateResultBase<ThinBlockWithCellsBean> {
  ThinBlockIsolateResultBean(status, errorMessage, result) : super(status, errorMessage, result);

  factory ThinBlockIsolateResultBean.fromSuccess(ThinBlockWithCellsBean result) =>
      ThinBlockIsolateResultBean(
        true,
        null,
        result,
      );

  factory ThinBlockIsolateResultBean.fromFail(Exception exception) => ThinBlockIsolateResultBean(
        false,
        exception,
        null,
      );
}
