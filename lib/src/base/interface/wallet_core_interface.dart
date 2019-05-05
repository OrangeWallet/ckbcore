abstract class WalletCoreInterface {
  cellsChanged();
  blockChanged();
  createStep(int step);
  storeWallet(String wallet, String password);
  getWallet(String password);
  syncedFinished();
}
