import 'package:ckb_sdk/ckb_address.dart';
import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/core/my_wallet.dart';

abstract class TransactionInterface {
  CellsResultBean get cellsResultBean;

  CKBApiClient get apiClient;

  Network get network;

  MyWallet get myWallet;
}
