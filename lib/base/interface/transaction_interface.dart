import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';
import 'package:ckb_sdk/ckb-utils/network.dart';
import 'package:ckbcore/base/bean/cells_result_bean.dart';
import 'package:ckbcore/base/core/my_wallet.dart';

abstract class TransactionInterface {
  CellsResultBean get cellsResultBean;

  CKBApiClient get apiClient;

  Network get network;

  MyWallet get myWallet;
}
