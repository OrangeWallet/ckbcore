import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckb_sdk/ckb_sdk.dart';

import '../../ckbcore_bean.dart';
import '../bean/cells_result_bean.dart';
import '../constant/constant.dart';
import '../utils/log.dart';
import 'fetch_rpc_utils/fetch_thin_block.dart';
import 'handle_synced_cells.dart';

class SyncInterface {
  Script lockScript;
  Function thinBlockUpdateFuc;
  Function getCellsBeanResult;
  Function syncException;
}

class SyncService {
  CKBApiClient _apiClient;
  bool _live = true;
  Function _intercept;
  final SyncInterface _syncInterface;

  SyncService(this._syncInterface) {
    _apiClient = CKBApiClient(Constant.NodeUrl);
  }

  start() {
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
        var cellsResult = _syncInterface.getCellsBeanResult();
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
          await _thinBlockUpdate(false, null, thinBlockWithCellsBean.thinBlock);
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
      await _syncInterface.thinBlockUpdateFuc(true, cellsResult);
    } else {
      _syncInterface.getCellsBeanResult().syncedBlockNumber = thinBlock.thinHeader.number;
      await _syncInterface.thinBlockUpdateFuc(false, cellsResult);
    }
  }
}
