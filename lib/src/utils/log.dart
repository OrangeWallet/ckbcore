import '../wallet_core.dart';

class Log {
  static log(Object log) {
    if (WalletCore.isDebug) print(log);
  }
}
