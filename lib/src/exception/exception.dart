import '../constant/constant.dart';

class LessThanMinCapacityException implements Exception {
  String toString() => "Capacity can't be less than ${MinCapacity}";
}

class NoEnoughCapacityException implements Exception {
  String toString() => "Capacity not enough";
}

class NoCodeHashException implements Exception {
  String toString() => "There is no code hash";
}

class EmptySeedException implements Exception {
  String toString() => 'Seed is Empty';
}

class IncorrectMnemonicException implements Exception {
  String toString() => 'Incorrect Mnemonic';
}
