import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/bean/thin_block.dart';
import 'package:ckbcore/base/config/hd_core_config.dart';
import 'package:ckbcore/base/constant/constant.dart' show ApiClient, NodeUrl;
import 'package:ckbcore/base/core/hd_core.dart';
import 'package:ckbcore/base/core/hd_index_wallet.dart';
import 'package:ckbcore/base/exception/exception.dart';
import 'package:ckbcore/base/interface/sync_interface.dart';
import 'package:ckbcore/base/interface/wallet_core_interface.dart';
import 'package:ckbcore/base/store/store_manager.dart';
import 'package:ckbcore/base/sync/sync_service.dart';
import 'package:ckbcore/base/utils/isolate_mnemonic_to_seed.dart';
import 'package:ckbcore/base/utils/log.dart';
import 'package:ckbcore/base/utils/searchCells/get_unspent_cells_utils.dart' as GetCellsUtils;
import 'package:ckbcore/base/utils/searchCells/update_unspent_cells.dart' as UpdateCellsUtils;
import 'package:convert/convert.dart';

abstract class WalletCore implements SyncInterface, WalletCoreInterface {
  static bool isDebug = true;

  HDCore _hdCore;
  SyncService _syncService;
  CellsResultBean _cellsResultBean = CellsResultBean([], '-1');
  HDCoreConfig _hdCoreConfig;
  StoreManager _storeManager;

  WalletCore(String storePath, String nodeUrl, bool _isDebug) {
    if (nodeUrl != null) {
      NodeUrl = nodeUrl;
      ApiClient = CKBApiClient(nodeUrl: NodeUrl);
    }
    isDebug = _isDebug;
    _storeManager = StoreManager(storePath);
  }

  HDIndexWallet get unusedReceiveWallet => _hdCore.unusedReceiveWallet;

  HDIndexWallet get unusedChangeWallet => _hdCore.unusedChangeWallet;

  CellsResultBean get cellsResultBean => _cellsResultBean;

  HDCoreConfig get hdCoreConfig => _hdCoreConfig;

  //Init HD Wallet from store
  Future init(String password) async {
    _hdCoreConfig = HDCoreConfig.fromJson(jsonDecode(await readWallet(password)));
    if (_hdCoreConfig.seed == '') {
      throw Exception('Seed is Empty');
    }
    _hdCore = HDCore(_hdCoreConfig);
    updateCurrentIndexCells();
    return;
  }

  //Create new HD Wallet
  Future create(String password) async {
    final mnemonic = bip39.generateMnemonic();
    Uint8List seed = await mnemonicToSeed(mnemonic);
    createStep(1);
    String seedStr = hex.encode(seed);
    _hdCoreConfig = HDCoreConfig(mnemonic, seedStr, 0, 0);
    _hdCore = HDCore(_hdCoreConfig);
    createStep(2);
    await writeWallet(jsonEncode(_hdCoreConfig), password);
    createStep(3);
    _syncService = SyncService(_hdCore, this);
    _cellsResultBean = await _storeManager.getSyncedCells();
    _cellsResultBean.syncedBlockNumber = '-1';
    await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
    updateCurrentIndexCells();
    return;
  }

  //Import HD Wallet
  Future import(String mnemonic, String password) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Wrong mnemonic');
    }
    Uint8List seed = await mnemonicToSeed(mnemonic);
    createStep(1);
    String seedStr = hex.encode(seed);
    _hdCoreConfig = HDCoreConfig(mnemonic, seedStr, 0, 0);
    _hdCore = HDCore(_hdCoreConfig);
    createStep(2);
    await writeWallet(jsonEncode(_hdCoreConfig), password);
    createStep(3);
    updateCurrentIndexCells();
    return;
  }

  updateCurrentIndexCells() async {
    try {
      _syncService = SyncService(_hdCore, this);
      _cellsResultBean = await _storeManager.getSyncedCells();
      if (_cellsResultBean.syncedBlockNumber == '') {
        Log.log('sync from genesis block');
        _cellsResultBean = await GetCellsUtils.getCurrentIndexCells(_hdCore, 0, (double processing) {
          syncProcess(processing);
        });
        await _storeManager.syncCells(_cellsResultBean);
      } else if (_cellsResultBean.syncedBlockNumber == '-1') {
        String targetBlockNumber = await ApiClient.getTipBlockNumber();
        Log.log('sync from tip block $targetBlockNumber');
        _cellsResultBean.syncedBlockNumber = targetBlockNumber;
        await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
      } else {
        Log.log('sync from ${_cellsResultBean.syncedBlockNumber}');
        var updateCellsResult =
            await UpdateCellsUtils.updateCurrentIndexCells(_hdCore, _cellsResultBean, (double processing) {
          syncProcess(processing);
        });
        if (updateCellsResult.isChange) {
          _cellsResultBean = updateCellsResult.cellsResultBean;
          await _storeManager.syncCells(_cellsResultBean);
        } else {
          _cellsResultBean.syncedBlockNumber = updateCellsResult.cellsResultBean.syncedBlockNumber;
          await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
        }
      }
      syncedFinished();
      _syncService.start((Exception e) => exception(e));
    } catch (e) {
      exception(SyncException());
    }
  }

  Future clearStore() async {
    await _storeManager.clearAll();
  }

  //Searching all cells.Include index before current receive index and change index
  // Future<CellsResultBean> _getWholeHDUnspentCells() async {
  //   _cellsResultBean = await GetCellsUtils.getWholeHDAllCells(_hdCore);
  //   await _storeManager.syncCells(_cellsResultBean);
  //   _syncService.start();
  //   return _cellsResultBean;
  // }

  @override
  Future thinBlockUpdate(bool isCellsChange, CellsResultBean cellsResult, ThinBlock thinBlock) async {
    try {
      if (isCellsChange) {
        _cellsResultBean = cellsResult;
        await _storeManager.syncCells(_cellsResultBean);
        cellsChanged();
      } else {
        _cellsResultBean.syncedBlockNumber = cellsResult.syncedBlockNumber;
        await _storeManager.syncBlockNumber(_cellsResultBean.syncedBlockNumber);
      }
      await blockChanged(thinBlock);
    } catch (e) {
      exception(BlockUpdateException(_cellsResultBean.syncedBlockNumber));
    }
  }

  @override
  CellsResultBean getCurrentCellsResult() {
    return _cellsResultBean;
  }
}
