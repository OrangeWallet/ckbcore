import 'package:ckb_sdk/ckb-rpc/ckb_api_client.dart';

final IntervalSyncTime = 20;
final IntervalBlockNumber = 100;
String NodeUrl = 'http://192.168.2.78:8114';
CKBApiClient ApiClient = CKBApiClient(NodeUrl);
