abstract class WalletCoreInterface {
  cellsChanged();
  blockChanged();
  createStep(int step);
  writeWallet(String wallet, String password);
  Future<String> readWallet(String password);
  syncedFinished();
  createFinished(bool isBackup);
}
