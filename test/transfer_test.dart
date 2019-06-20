import 'package:ckb_sdk/ckb_sdk.dart';
import 'package:ckbcore/src/bean/cell_bean.dart';
import 'package:ckbcore/src/bean/receiver_bean.dart';
import 'package:ckbcore/src/store/store_manager.dart';
import 'package:ckbcore/src/transction/transaction_manager.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  test('transfer ckb', () async {
    String privateKey = "e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3";
    ReceiverBean receiver =
        ReceiverBean("ckt1q9gry5zgmm7cgrx5thr4cwf6fmkvxq4e7yrfczhz0papsv", 6000000000);
    StoreManager storeManager = StoreManager('test/store/store');
    List<CellBean> cells = (await storeManager.getSyncedCells()).cells;
    String hash = await sendCapacity(hex.decode(privateKey), cells, [receiver], CKBNetwork.Testnet);
    print(hash);
  });
}
