import 'package:ckb_sdk/ckb_address.dart';
import 'package:ckb_sdk/ckb_rpc.dart';

import '../bean/cells_result_bean.dart';
import '../core/my_wallet.dart';

abstract class TransactionInterface {
  CellsResultBean get cellsResultBean;

  CKBApiClient get apiClient;

  Network get network;

  MyWallet get myWallet;
}
