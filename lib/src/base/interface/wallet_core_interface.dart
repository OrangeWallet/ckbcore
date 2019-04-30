import 'package:ckbcore/src/base/config/hd_core_config.dart';

abstract class WalletCoreInterface {
  cellsChanged();
  blockChanged();
  createStep(int step);
  storeWallet(String wallet);
  Future<HDCoreConfig> getWallet();
  syncedFinished();
}
