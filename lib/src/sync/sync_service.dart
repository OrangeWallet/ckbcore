import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckb_sdk/ckb_sdk.dart';

import '../../ckbcore_bean.dart';
import '../bean/cells_result_bean.dart';
import '../constant/constant.dart';
import '../interface/sync_interface.dart';
import '../utils/log.dart';
import 'fetch_rpc_utils/fetch_thin_block.dart';
import 'handle_synced_cells.dart';

class SyncService {
  CKBApiClient _apiClient;
  Script _lockScript;
  SyncInterface _syncInterface;
  Function _thinBlockUpdateFuc;
  bool _live = true;
  Function _intercept;

  SyncService(this._lockScript, this._syncInterface, this._thinBlockUpdateFuc) {
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
      while (int.parse(_syncInterface.cellsResultBean.syncedBlockNumber) < targetBlockNumber &&
          _live) {
        int syncedBlockNumber = int.parse(_syncInterface.cellsResultBean.syncedBlockNumber) + 1;
        Log.log(
            'synced is ${syncedBlockNumber - 1},fetch block ${syncedBlockNumber},target is ${targetBlockNumber}');
        var thinBlockWithCellsBean = await fetchBlockToCheckCell(
            FetchBlockToCheckParam(_lockScript, syncedBlockNumber, _apiClient));
        if (thinBlockWithCellsBean.newCells.length > 0 ||
            thinBlockWithCellsBean.spendCells.length > 0) {
          var cells =
              await handleSyncedCells(_syncInterface.cellsResultBean.cells, thinBlockWithCellsBean);
          await _thinBlockUpdate(
              true,
              CellsResultBean(cells, thinBlockWithCellsBean.thinBlock.thinHeader.number),
              thinBlockWithCellsBean.thinBlock);
        } else {
          await _thinBlockUpdate(false, null, thinBlockWithCellsBean.thinBlock);
        }
      }
      Log.log('synced is ${_syncInterface.cellsResultBean.syncedBlockNumber},It`s tip,waiting');
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
      await _thinBlockUpdateFuc(true, cellsResult);
    } else {
      this._syncInterface.cellsResultBean.syncedBlockNumber = thinBlock.thinHeader.number;
      await _thinBlockUpdateFuc(false, cellsResult);
    }
  }
}
