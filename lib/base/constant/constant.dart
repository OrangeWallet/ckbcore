import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';

final IntervalSyncTime = 20;
final IntervalBlockNumber = 100;
final MinCapacity = 40;
String NodeUrl = 'http://192.168.99.123:8114';
CKBApiClient ApiClient = CKBApiClient(NodeUrl);
