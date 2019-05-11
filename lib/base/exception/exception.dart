import 'package:ckbcore/base/constant/constant.dart';

class LessThanMinCapacityException implements Exception {
  String toString() => "Capacity can't be less than ${MinCapacity}";
}

class NoEnoughCapacityException implements Exception {
  String toString() => "Capacity not enough";
}
