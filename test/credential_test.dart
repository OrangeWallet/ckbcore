import 'package:ckb_sdk/ckb_address.dart' show CKBNetwork;
import 'package:ckbcore/src/core/credential.dart';
import 'package:test/test.dart';

void main() {
  test('from hex', () {
    Credential credential = Credential.fromPrivateKeyHex(
        "e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3");
    expect(credential.getAddress(CKBNetwork.Testnet),
        "ckt1q9gry5zgxmpjnmtrp4kww5r39frh2sm89tdt2l6v234ygf");
  });
}
