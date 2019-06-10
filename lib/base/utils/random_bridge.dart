/**
Copyright 2019 Simon Binder

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
import 'dart:math';
import 'dart:typed_data';

import 'package:ckb_sdk/ckb-utils/number.dart';
import 'package:pointycastle/api.dart';

/// Utility to use dart:math's Random class to generate numbers used by
/// pointycastle.
class RandomBridge implements SecureRandom {
  Random dartRandom;

  RandomBridge(this.dartRandom);

  @override
  String get algorithmName => 'DartRandom';

  @override
  BigInt nextBigInteger(int bitLength) {
    final fullBytes = bitLength ~/ 8;
    final remainingBits = bitLength % 8;

    // Generate a number from the full bytes. Then, prepend a smaller number
    // covering the remaining bits.
    final main = bytesToInt(nextBytes(fullBytes));
    final additional = dartRandom.nextInt(1 << remainingBits);
    return main + (BigInt.from(additional) << (fullBytes * 8));
  }

  @override
  Uint8List nextBytes(int count) {
    final list = Uint8List(count);

    for (var i = 0; i < list.length; i++) {
      list[i] = nextUint8();
    }

    return list;
  }

  @override
  int nextUint16() => dartRandom.nextInt(1 << 16);

  @override
  int nextUint32() => dartRandom.nextInt(1 << 32);

  @override
  int nextUint8() => dartRandom.nextInt(1 << 8);

  @override
  void seed(CipherParameters params) {
    // ignore, dartRandom will already be seeded if wanted
  }
}
