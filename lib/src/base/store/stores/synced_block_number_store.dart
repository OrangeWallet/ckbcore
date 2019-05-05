import 'dart:io';

import 'package:ckbcore/src/base/utils/file.dart';

class SyncedBlockNumberStore {
  final String dirPath;
  File _blockNumberFile;
  String _blockNumberFilePath;
  String _SYNCEDBLOCKNUMBER = 'syncedBlockNumber.txt';

  SyncedBlockNumberStore(this.dirPath) {
    if (dirPath.substring(dirPath.length - 1) == '/')
      _blockNumberFilePath = dirPath + _SYNCEDBLOCKNUMBER;
    else
      _blockNumberFilePath = dirPath + '/' + _SYNCEDBLOCKNUMBER;

    _blockNumberFile = File(_blockNumberFilePath);
    if (!_blockNumberFile.existsSync()) {
      _blockNumberFile.createSync(recursive: true);
    }
  }

  Future<String> readFromStore() async {
    return await readFromFile(_blockNumberFile);
  }

  Future wirteToStore(String blockNumber) async {
    await writeToFile(blockNumber, _blockNumberFile);
    return;
  }

  Future deleteStore() async {
    await wirteToStore('');
    return;
  }
}
