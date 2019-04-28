import 'dart:convert';
import 'dart:io';

import 'package:ckbcore/src/base/bean/cells_result_bean.dart';
import 'package:ckbcore/src/base/utils/file.dart';

class CellsStore {
  final String dirPath;
  String _filePath;
  String _CELLS = 'cells.json';

  CellsStore(this.dirPath) {
    if (dirPath.substring(dirPath.length - 1) == '/')
      _filePath = dirPath + _CELLS;
    else
      _filePath = dirPath + '/' + _CELLS;

    File file = File(_filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
  }

  Future<CellsResultBean> getFromStore() async {
    String data = await readFromFile(_filePath);
    CellsResultBean cellsResultBean;
    if (data != '') {
      cellsResultBean = CellsResultBean.fromJson(jsonDecode(data));
    } else {
      cellsResultBean = CellsResultBean([], '-1');
    }
    return cellsResultBean;
  }

  Future saveToStore(CellsResultBean data) async {
    String str = jsonEncode(data);
    await writeToFile(str, _filePath);
  }
}
