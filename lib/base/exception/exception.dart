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
