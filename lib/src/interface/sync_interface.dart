import '../bean/cells_result_bean.dart';

abstract class SyncInterface {
  CellsResultBean get cellsResultBean;

  syncException(Exception e);
}
