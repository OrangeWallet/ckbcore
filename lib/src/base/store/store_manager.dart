import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/store/stores/cell_store.dart';
import 'package:ckbcore/src/base/store/stores/synced_block_number_store.dart';

class StoreManager {
  CellsStore _cellsStore;
  SyncedBlockNumberStore _syncedBlockNumberStore;

  StoreManager(String dirPath) {
    _cellsStore = CellsStore(dirPath);
    _syncedBlockNumberStore = SyncedBlockNumberStore(dirPath);
  }

  Future syncBlockNumber(String blockNumber) async {
    await _syncedBlockNumberStore.wirteToStore(blockNumber);
  }

  Future syncCells(String blockNumber, List<CellBean> cells) async {
    await _syncedBlockNumberStore.wirteToStore(blockNumber);
    await _cellsStore.writeToStore(cells);
  }

  Future<CellsResultBean> getSyncedCells() async {
    List<CellBean> cells = await _cellsStore.readFromStore();
    String syncedBlockNumber = await _syncedBlockNumberStore.readFromStore();
    return CellsResultBean(cells, syncedBlockNumber);
  }
}
