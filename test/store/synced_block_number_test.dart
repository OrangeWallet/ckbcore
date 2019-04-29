import 'package:ckbcore/src/base/store/synced_block_number_store.dart';
import 'package:test/test.dart';

main() {
  SyncedBlockNumberStore syncedBlockNumberStore = SyncedBlockNumberStore('test/store/store');

  test('read from store', () async {
    String blockNumber = await syncedBlockNumberStore.readFromStore();
    print(blockNumber);
  });

  test('write from store', () async {
    await syncedBlockNumberStore.wirteToStore('12');
  });
}
