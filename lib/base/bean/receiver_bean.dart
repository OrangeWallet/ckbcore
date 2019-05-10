import 'package:ckb_sdk/ckb-utils/network.dart';

class ReceiverBean {
  final String address;
  final int capacity;
  final Network network;

  ReceiverBean(this.address, this.capacity, this.network);
}
