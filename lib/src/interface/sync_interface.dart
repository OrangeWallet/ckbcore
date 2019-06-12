import '../bean/cells_result_bean.dart';
import '../bean/thin_block.dart';

abstract class SyncInterface {
  thinBlockUpdate(bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock);

  CellsResultBean get cellsResultBean;

  syncException(Exception e);
}
