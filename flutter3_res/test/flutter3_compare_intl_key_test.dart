import 'dart:convert';
import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/26
///
/// 比对2个arb文件中的key
/// - 输出b文件在a文件中不存在的key
void main() {
  print("当前路径->${Directory.current.path}");
  final aFile = File("lib/l10n/intl_zh.arb");
  final bFile = File("lib/l10n/intl_en.arb");
  final aJson = jsonDecode(aFile.readAsStringSync());
  final bJson = jsonDecode(bFile.readAsStringSync());

  final diffJson = {};
  for (final key in aJson.keys) {
    if (!bJson.containsKey(key)) {
      diffJson[key] = aJson[key];
    }
  }
  if (diffJson.isNotEmpty) {
    print("${bFile.path} 在 ${aFile.path} 中不存在的key:");
    print(JsonEncoder.withIndent("  ").convert(diffJson));
  }

  final diffJson2 = {};
  for (final key in bJson.keys) {
    if (!aJson.containsKey(key)) {
      diffJson2[key] = bJson[key];
    }
  }
  if (diffJson2.isNotEmpty) {
    print("${aFile.path} 在 ${bFile.path} 中不存在的key:");
    print(JsonEncoder.withIndent("  ").convert(diffJson2));
  }

  print("A keys: ${aJson.keys.length} / B keys: ${bJson.keys.length}");
}
