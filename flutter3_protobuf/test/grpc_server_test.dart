import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_protobuf/flutter3_protobuf.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/12
///
void main() async {
  l.d(Platform.operatingSystem);
  l.d(Platform.localeName);
  l.d(Platform.environment.containsKey('FLUTTER_TEST'));
  await startTestRpcServer();
  final result = await testRpcClient();
  l.i(result);
}
