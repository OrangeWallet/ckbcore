import 'package:ckb_sdk/ckb_rpc.dart';
import 'package:ckbcore/src/bean/cells_result_bean.dart';
import 'package:ckbcore/src/constant/constant.dart';
import 'package:ckbcore/src/core/credential.dart';
import 'package:ckbcore/src/core/my_wallet.dart';
import 'package:ckbcore/src/sync/get_cells_utils/get_unspent_cells.dart';
import 'package:ckbcore/src/utils/log.dart';
import 'package:test/test.dart';

main() {
  String privateKey = 'e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3';

  test('get current index cells', () async {
    CellsResultBean cells = await getCurrentIndexCells(
        MyWallet(Credential.fromPrivateKeyHex(privateKey).publicKey).lockHash,
        0,
        CKBApiClient(Constant.NodeUrl), (double processing) {
      print(processing);
    });
    Log.log(cells.cells.length);
  });
}
