import '../cell_bean.dart';
import 'isolate_result_base.dart';

class CellsIsolateResultBean extends IsolateResultBase<List<CellBean>> {
  CellsIsolateResultBean(status, errorMessage, result) : super(status, errorMessage, result);

  factory CellsIsolateResultBean.fromSuccess(List<CellBean> result) => CellsIsolateResultBean(
        true,
        null,
        result,
      );

  factory CellsIsolateResultBean.fromFail(Exception exception) => CellsIsolateResultBean(
        false,
        exception,
        null,
      );
}
