import 'package:ckbcore/src/base/bean/cell_bean.dart';

class CellsResultBean {
  final List<CellBean> cells;
  final String syncedBlockNumber;

  CellsResultBean(this.cells, this.syncedBlockNumber);
}
