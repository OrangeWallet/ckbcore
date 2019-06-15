import 'dart:math';
import 'dart:typed_data';

import 'package:ckbcore/src/core/keystore.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  Uint8List privateKey =
      hex.decode("e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3");
  String password = "12345678";

  String json =
      '{"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"3e6e077787acd48934bdf435639c0e14"},"ciphertext":"c1419643f546b5df02bcec7f0376841e7100520c5df57bf92601ef1171a9c2e","kdf":"scrypt","kdfparams":{"dklen":32,"n":8192,"r":8,"p":1,"salt":"200986f2d4644102ac46827581a05716dd971c303bfeb672b1f37dfbf491038"},"mac":"7b6f0285903360fecb514db38243931e195c8eec8973fc4532c5f78f304158cf"},"id":"cb207b6a-f9ec-4b95-96f1-04c5d700989a","version":3}';

  test('keystore', () {
    var keystore = Keystore.createNew(privateKey, password, Random.secure());
    var json = keystore.toJson();
    var keystore2 = Keystore.fromJson(json, password);
    expect(privateKey, keystore2.privateKey);
  });

  test('fromJson', () {
    var keystore = Keystore.fromJson(json, '1qaz.2wsx');
    print(hex.encode(keystore.privateKey));
  });
}
