import '../bean/balance_bean.dart';
import '../bean/thin_block.dart';

abstract class WalletCoreInterface {
  cellsChanged(BalanceBean balance);

  blockChanged(ThinBlock thinBlock);

  syncProcess(double processing);

  syncException(Exception e);
}
