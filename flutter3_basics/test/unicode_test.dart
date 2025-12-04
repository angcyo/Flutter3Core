import 'dart:convert';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/04
///
/// # 官方 Unicode 字符表
/// https://www.unicode.org/charts/
///
/// # List of Unicode Symbols
/// https://symbl.cc/en/unicode-table/
void main() {
  /*你
  [20320]
  (100111101100000)
  (4F60)

  [228, 189, 160]
  (11100100, 10111101, 10100000)
  (E4, BD, A0)*/
  final text = "你";
  print(text);
  print(text.codeUnits); // 码点
  print(text.codeUnits.map((e) => e.toRadixString(2)));
  print(text.codeUnits.map((e) => e.toRadixString(16).toUpperCase()));
  print("");
  print(utf8.encode(text));
  print(utf8.encode(text).map((e) => e.toRadixString(2)));
  print(utf8.encode(text).map((e) => e.toRadixString(16).toUpperCase()));
}
