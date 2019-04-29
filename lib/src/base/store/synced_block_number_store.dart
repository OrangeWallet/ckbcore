import 'dart:io';

import 'package:ckbcore/src/base/utils/file.dart';

class SyncedBlockNumberStore {
  final String dirPath;
  String _blockNumberFilePath;
  String _SYNCEDBLOCKNUMBER = 'syncedBlockNumber.txt';

  SyncedBlockNumberStore(this.dirPath) {
    if (dirPath.substring(dirPath.length - 1) == '/')
      _blockNumberFilePath = dirPath + _SYNCEDBLOCKNUMBER;
    else
      _blockNumberFilePath = dirPath + '/' + _SYNCEDBLOCKNUMBER;

    File blockNumberFile = File(_blockNumberFilePath);
    if (!blockNumberFile.existsSync()) {
      blockNumberFile.createSync(recursive: true);
    }
  }

  Future<String> readFromStore() async {
    return await readFromFile(_blockNumberFilePath);
  }

  Future wirteToStore(String number) async {
    await writeToFile(number, _blockNumberFilePath);
  }
}
