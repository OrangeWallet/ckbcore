import 'dart:math';
import 'dart:typed_data';

import 'package:ckbcore/base/core/keystore.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

main() {
  Uint8List privateKey =
      hex.decode("e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3");
  String password = "12345678";
  test('keystore', () {
    var keystore = Keystore.createNew(privateKey, password, Random());
    var json = keystore.toJson();
    var keystore2 = Keystore.fromJson(json, password);
    expect(privateKey, keystore2.privateKey);
  });
}
