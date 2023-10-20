import 'dart:ui';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region 基础扩展

int nowTime() => DateTime.now().millisecondsSinceEpoch;

extension ColorEx on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(buffer.toString().toInt(radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension StringEx on String {
  /// 字符串转换成int
  toInt({int? radix}) => int.parse(this, radix: radix);

  /// 字符串转换成int
  toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// 字符转换成Color对象
  toColor() => ColorEx.fromHex(this);

  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  toDateTime() => DateTime.parse(this);
}

/// https://pub.dev/packages/date_format
/*extension DateTimeEx on DateTime {
  toFormatString() {
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(this);
  }
}*/

//endregion 基础扩展
