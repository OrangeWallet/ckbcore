import 'package:ckbcore/base/bean/thin_block.dart';

abstract class WalletCoreInterface {
  cellsChanged();
  blockChanged(ThinBlock thinBlock);
  syncProcess(double processing);
  createStep(int step);
  writeWallet(String wallet, String password);
  Future<String> readWallet(String password);
  syncedFinished();
  createFinished(bool isBackup);
  exception(Exception e);
}
