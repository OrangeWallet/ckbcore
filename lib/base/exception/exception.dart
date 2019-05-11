import 'package:ckbcore/base/constant/constant.dart';

class SyncException implements Exception {
  String e;

  SyncException(this.e);

  String toString() => e;
}

class BlockUpdateException implements Exception {
  String blockNumber;

  BlockUpdateException(this.blockNumber);

  String toString() => "Block update to $blockNumber";
}

class LessThanMinCapacityException implements Exception {
  String toString() => "Capacity can't be less than ${MinCapacity}";
}

class NoEnoughCapacityException implements Exception {
  String toString() => "Capacity not enough";
}
