import 'dart:convert';
import 'dart:io';

import 'package:ckbcore/src/base/bean/cell_bean.dart';
import 'package:ckbcore/src/base/utils/file.dart';

class CellsStore {
  final String dirPath;
  File _cellsFile;
  String _cellsFilePath;
  String _CELLS = 'cells.json';

  CellsStore(this.dirPath) {
    if (dirPath.substring(dirPath.length - 1) == '/')
      _cellsFilePath = dirPath + _CELLS;
    else
      _cellsFilePath = dirPath + '/' + _CELLS;

    _cellsFile = File(_cellsFilePath);
    if (!_cellsFile.existsSync()) {
      _cellsFile.createSync(recursive: true);
    }
  }

  Future<List<CellBean>> readFromStore() async {
    String data = await readFromFile(_cellsFile);
    if (data != '') {
      var list = jsonDecode(data) as List;
      List<CellBean> cells = list.map((e) => CellBean.fromJson(e as Map<String, dynamic>)).toList();
      return cells;
    } else {
      return [];
    }
  }

  Future writeToStore(List<CellBean> data) async {
    String str = jsonEncode(data);
    await writeToFile(str, _cellsFile);
    return;
  }

  Future deleteStore() async {
    await _cellsFile.deleteSync();
    return;
  }
}
