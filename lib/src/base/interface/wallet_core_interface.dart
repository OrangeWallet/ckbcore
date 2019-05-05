abstract class WalletCoreInterface {
  cellsChanged();
  blockChanged();
  createStep(int step);
  writeWallet(String wallet, String password);
  readWallet(String password);
  syncedFinished();
}
