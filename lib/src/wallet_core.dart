import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/bean/thin_block.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/core/hd_index_wallet.dart';
import 'package:ckbcore/src/base/interface/sync_interface.dart';
import 'package:ckbcore/src/base/interface/wallet_core_interface.dart';
import 'package:ckbcore/src/base/store/store_manager.dart';
import 'package:ckbcore/src/base/sync/sync_service.dart';
import 'package:ckbcore/src/base/utils/isolate_mnemonic_to_seed.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart' as GetCellsUtils;
import 'package:ckbcore/src/base/utils/searchCells/update_unspent_cells.dart' as UpdateCellsUtils;
import 'package:convert/convert.dart';

abstract class WalletCore implements SyncInterface, WalletCoreInterface {
  static StoreManager MyStoreManager;
  static int IntervalBlockNumber = 100;
  static int IntervalSyncTime = 20;
  static String DefaultNodeUrl = 'http://192.168.2.225:8114';

  HDCore _hdCore;
  SyncService _syncService;
  CellsResultBean _cellsResultBean = CellsResultBean([], '-1');

  WalletCore(String storePath, {String nodeUrl}) {
    DefaultNodeUrl = nodeUrl == null ? DefaultNodeUrl : nodeUrl;
    MyStoreManager = StoreManager(storePath);
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  CellsResultBean get cellsResultBean => _cellsResultBean;

  Future init() async {
    HDCoreConfig config = await getWallet();
    if (config.seed == '') {
      throw Exception('Seed is Empty');
    }
    _hdCore = HDCore(config);
    return;
  }

  Future create(String mnemonic) async {
    if (mnemonic == '') {
      mnemonic = bip39.generateMnemonic();
    }
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Wrong mnemonic');
    }
    Uint8List seed = await mnemonicToSeed(mnemonic);
    createStep(1);
    String seedStr = hex.encode(seed);
    var hdCoreConfig = HDCoreConfig(mnemonic, seedStr, 0, 0);
    _hdCore = HDCore(hdCoreConfig);
    createStep(2);
    await storeWallet(jsonEncode(hdCoreConfig));
    createStep(3);
    return;
  }

  updateCurrentIndexCells() async {
    _syncService = SyncService(_hdCore, this);
    _cellsResultBean = await MyStoreManager.getSyncedCells();
    if (_cellsResultBean.syncedBlockNumber == '') {
      print('sync from genesis block');
      _cellsResultBean = await GetCellsUtils.getCurrentIndexCells(_hdCore, 0);
      await MyStoreManager.syncCells(_cellsResultBean);
    } else {
      print('sync from ${_cellsResultBean.syncedBlockNumber}');
      var updateCellsResult = await UpdateCellsUtils.updateCurrentIndexCells(_hdCore, _cellsResultBean);
      if (updateCellsResult.isChange) {
        _cellsResultBean = updateCellsResult.cellsResultBean;
        await MyStoreManager.syncCells(_cellsResultBean);
      } else {
        _cellsResultBean.syncedBlockNumber = updateCellsResult.cellsResultBean.syncedBlockNumber;
        await MyStoreManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
      }
    }
    syncedFinished();
    _syncService.start();
  }

  //Searching all cells.Include index before current receive index and change index
  Future<CellsResultBean> _getWholeHDUnspentCells() async {
    _cellsResultBean = await GetCellsUtils.getWholeHDAllCells(_hdCore);
    await MyStoreManager.syncCells(_cellsResultBean);
    _syncService.start();
    return _cellsResultBean;
  }

  @override
  Future thinBlockUpdate(bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock) async {
    if (isCellsChange) {
      _cellsResultBean = cellsResult;
      await MyStoreManager.syncCells(_cellsResultBean);
      cellsChanged();
    } else {
      _cellsResultBean.syncedBlockNumber = cellsResult.syncedBlockNumber;
      await MyStoreManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    }
    blockChanged();
    return;
  }

  @override
  CellsResultBean getCurrentCellsResult() {
    return _cellsResultBean;
  }
}
