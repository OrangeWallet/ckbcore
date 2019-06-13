import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckb_sdk/ckb_sdk.dart';

import '../../ckbcore_bean.dart';
import '../bean/cells_result_bean.dart';
import '../constant/constant.dart';
import '../store/store_manager.dart';
import '../utils/log.dart';
import 'fetch_rpc_utils/fetch_thin_block.dart';
import 'get_cells_utils/get_unspent_cells.dart';
import 'get_cells_utils/update_unspent_cells.dart';
import 'handle_synced_cells.dart';

class SyncInterface {
  Script lockScript;
  StoreManager storeManager;
  CellsResultBean cellsResultBean;
  Function getCellsBeanResult;
  Function setCellsBeanResult;
  Function syncException;
  Function calculateBalance;
  Function syncProcess;
  Function blockChanged;
}

class SyncService {
  CKBApiClient _apiClient;
  bool _live = true;
  Function _intercept;
  final SyncInterface _syncInterface;

  SyncService(this._syncInterface) {
    _apiClient = CKBApiClient(Constant.NodeUrl);
  }

  start() async {
    try {
      var cellsResultBean = _syncInterface.getCellsBeanResult();
      await _syncInterface.calculateBalance();
      if (cellsResultBean.syncedBlockNumber == '') {
        Log.log('sync from genesis block');
        cellsResultBean = await getCurrentIndexCells(
            _syncInterface.lockScript.scriptHash, 0, _apiClient, (double processing) {
          _syncInterface.syncProcess(processing);
        });
        _syncInterface.setCellsBeanResult(cellsResultBean);
        await _syncInterface.storeManager.syncCells(cellsResultBean);
      } else if (cellsResultBean.syncedBlockNumber == '-1') {
        String targetBlockNumber = await _apiClient.getTipBlockNumber();
        Log.log('sync from tip block $targetBlockNumber');
        cellsResultBean.syncedBlockNumber = targetBlockNumber;
        _syncInterface.setCellsBeanResult(cellsResultBean);
        await _syncInterface.storeManager.syncBlockNumber(cellsResultBean.syncedBlockNumber);
      } else {
        Log.log('sync from ${cellsResultBean.syncedBlockNumber}');
        var updateCellsResult = await updateUnspentCells(
            _syncInterface.lockScript.scriptHash, cellsResultBean, _apiClient, (double processing) {
          _syncInterface.syncProcess(processing);
        });
        if (updateCellsResult.isChange) {
          _syncInterface.setCellsBeanResult(updateCellsResult.cellsResultBean);
          await _syncInterface.storeManager.syncCells(cellsResultBean);
        } else {
          cellsResultBean.syncedBlockNumber = updateCellsResult.cellsResultBean.syncedBlockNumber;
          _syncInterface.setCellsBeanResult(cellsResultBean);
          await _syncInterface.storeManager.syncBlockNumber(cellsResultBean.syncedBlockNumber);
        }
      }
      await _syncInterface.calculateBalance();
      _syncInterface.syncProcess(1.0);
    } catch (e) {
      _syncInterface.syncException(e);
    }
    _live = true;
    _rotation();
  }

  stop(Function intercept) {
    _intercept = intercept;
    _live = false;
  }

  _rotation() async {
    try {
      if (_intercept != null && !_live) {
        _intercept();
        _intercept = null;
        return;
      }
      int targetBlockNumber = int.parse(await _apiClient.getTipBlockNumber());
      while (int.parse(_syncInterface.getCellsBeanResult().syncedBlockNumber) < targetBlockNumber &&
          _live) {
        CellsResultBean cellsResult = _syncInterface.getCellsBeanResult();
        int syncedBlockNumber = int.parse(cellsResult.syncedBlockNumber) + 1;
        Log.log(
            'synced is ${syncedBlockNumber - 1},fetch block ${syncedBlockNumber},target is ${targetBlockNumber}');
        var thinBlockWithCellsBean = await fetchBlockToCheckCell(
            FetchBlockToCheckParam(_syncInterface.lockScript, syncedBlockNumber, _apiClient));
        if (thinBlockWithCellsBean.newCells.length > 0 ||
            thinBlockWithCellsBean.spendCells.length > 0) {
          var cells = await handleSyncedCells(cellsResult.cells, thinBlockWithCellsBean);
          await _thinBlockUpdate(
              true,
              CellsResultBean(cells, thinBlockWithCellsBean.thinBlock.thinHeader.number),
              thinBlockWithCellsBean.thinBlock);
        } else {
          cellsResult.syncedBlockNumber = thinBlockWithCellsBean.thinBlock.thinHeader.number;
          await _thinBlockUpdate(false, cellsResult, thinBlockWithCellsBean.thinBlock);
        }
      }
      Log.log('It`s tip,waiting');
      await Future.delayed(Duration(seconds: Constant.IntervalSyncTime), () async {
        await _rotation();
      });
    } catch (e) {
      if (e is Exception) {
        _syncInterface.syncException(e);
      } else {
        _syncInterface.syncException(Exception(e.toString()));
      }
    }
  }

  Future _thinBlockUpdate(
      bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock) async {
    if (isCellsChange) {
      await _syncInterface.storeManager.syncCells(cellsResult);
      _syncInterface.setCellsBeanResult(cellsResult);
      await _syncInterface.calculateBalance();
    } else {
      _syncInterface.setCellsBeanResult(cellsResult);
      await _syncInterface.storeManager.syncBlockNumber(cellsResult.syncedBlockNumber);
    }
    await _syncInterface.blockChanged(thinBlock);
  }
}
