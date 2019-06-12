import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/constant/constant.dart';
import 'package:ckbcore/base/core/my_wallet.dart';
import 'package:ckbcore/base/interface/sync_interface.dart';
import 'package:ckbcore/base/sync/handle_synced_cells.dart';
import 'package:ckbcore/base/utils/fetch_rpc_utils/fetch_thin_block.dart';
import 'package:ckbcore/base/utils/log.dart';

class SyncService {
  CKBApiClient _apiClient;
  MyWallet _myWallet;
  SyncInterface _syncInterface;
  bool _live = true;
  Function _intercept;

  SyncService(this._myWallet, this._syncInterface, this._apiClient);

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
            FetchBlockToCheckParam(_myWallet, syncedBlockNumber, _apiClient));
        if (thinBlockWithCellsBean.newCells.length > 0 ||
            thinBlockWithCellsBean.spendCells.length > 0) {
          var cells =
              await handleSyncedCells(_syncInterface.cellsResultBean.cells, thinBlockWithCellsBean);
          await _syncInterface.thinBlockUpdate(
              true,
              CellsResultBean(cells, thinBlockWithCellsBean.thinBlock.thinHeader.number),
              thinBlockWithCellsBean.thinBlock);
        } else {
          await _syncInterface.thinBlockUpdate(false, null, thinBlockWithCellsBean.thinBlock);
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
}
