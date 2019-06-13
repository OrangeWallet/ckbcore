import '../bean/balance_bean.dart';
import '../bean/thin_block.dart';

abstract class WalletCoreInterface {
  cellsChanged(BalanceBean balance);

  blockChanged(ThinBlock thinBlock);

  syncProcess(double processing);

  createStep(int step);

  writeWallet(String wallet, String password);

  Future<String> readWallet(String password);

  syncException(Exception e);
}
