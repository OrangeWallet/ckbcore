import 'dart:typed_data';

class HDCoreConfig {
  final Uint8List seed;
  final int receiveIndex;
  final int changeIndex;
  HDCoreConfig(this.seed, this.receiveIndex, this.changeIndex);
}
