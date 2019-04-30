import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/config/hd_core_config.dart';
import 'package:ckbcore/src/base/core/hd_core.dart';
import 'package:ckbcore/src/base/utils/searchCells/get_unspent_cells_utils.dart';
import 'package:test/test.dart';

main() {
  Uint8List privateKey =
      intToBytes(toBigInt(remove0x('e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3')));
  HDCore hdCore = HDCore(HDCoreConfig(privateKey, 0, 0));

  test('get current index cells', () async {
    CellsResultBean cells = await getCurrentIndexCells(hdCore, 0);
    print(cells.cells.length);
  });
}
