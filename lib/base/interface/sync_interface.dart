import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';

abstract class SyncInterface {
  thinBlockUpdate(bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock);
  CellsResultBean getCurrentCellsResult();
}
