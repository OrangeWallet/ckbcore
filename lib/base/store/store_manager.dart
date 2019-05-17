import 'package:ckbcore/base/bean/cell_bean.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/store/stores/cell_store.dart';
import 'package:ckbcore/base/store/stores/synced_block_number_store.dart';

class StoreManager {
  CellsStore _cellsStore;
  SyncedBlockNumberStore _syncedBlockNumberStore;

  StoreManager(String dirPath) {
    _cellsStore = CellsStore(dirPath);
    _syncedBlockNumberStore = SyncedBlockNumberStore(dirPath);
  }

  Future syncBlockNumber(String blockNumber) async {
    await _syncedBlockNumberStore.writeToStore(blockNumber);
    return;
  }

  Future syncCells(CellsResultBean cellsResultBeean) async {
    await _syncedBlockNumberStore.writeToStore(cellsResultBeean.syncedBlockNumber);
    await _cellsStore.writeToStore(cellsResultBeean.cells);
    return;
  }

  Future<CellsResultBean> getSyncedCells() async {
    List<CellBean> cells = await _cellsStore.readFromStore();
    String syncedBlockNumber = await _syncedBlockNumberStore.readFromStore();
    return CellsResultBean(cells, syncedBlockNumber);
  }

  Future clearAll() async {
    await _cellsStore.deleteStore();
    await _syncedBlockNumberStore.deleteStore();
  }
}
