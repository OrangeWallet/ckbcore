import 'package:ckb_sdk/ckb-utils/number.dart' as number;
import 'package:orange_wallet_core/src/base/core/credential.dart';
import 'package:test/test.dart';

void main() {
  test('from hex', () {
    Credential credential = Credential.fromPrivateKeyHex(
        "e79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3");
    String pb = number.toHex(credential.publicKey);
    String privateKeyHex = number.toHex(credential.privateKey);
    print(credential.privateKey);
    print(privateKeyHex);
    print(credential.publicKey);
    print(pb);
  });
}
