class SyncException implements Exception {
  String toString() => "Sync Error";
}

class BlockUpdateException implements Exception {
  String blockNumber;

  BlockUpdateException(this.blockNumber);

  String toString() => "Block update to $blockNumber";
}
