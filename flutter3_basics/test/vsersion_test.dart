import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/04
///
void main() {
  final config = "0.0.2~0.1.0 1.0.0~1.0.1 100~999";
  final rangeList = VersionMatcher.parseRange(config);
  print('rangeList: $rangeList');
  print('match: ${VersionMatcher.matches("0.0.1", config)}');
  print('match: ${VersionMatcher.matches("0.0.2", config)}');
  print('match: ${VersionMatcher.matches(1, config)}');
  print('match: ${VersionMatcher.matches(111, config)}');
}
