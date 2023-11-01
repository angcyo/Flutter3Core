part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region Color 扩展

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

//endregion Color 扩展

//region String 扩展

extension StringEx on String {
  /// 字符串转换成int
  toInt({int? radix}) => int.parse(this, radix: radix);

  /// 字符串转换成int
  toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// 字符转换成Color对象
  toColor() => ColorEx.fromHex(this);

  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  toDateTime() => DateTime.parse(this);

  /// 确保前缀是指定的字符串
  ensurePrefix(String prefix) {
    if (!startsWith(prefix)) {
      return '$prefix$this';
    }
    return this;
  }
}

//endregion String 扩展

//region Rect 扩展

extension RectEx on Rect {
  /// [Rect]的中心点
  Offset get center => Offset.fromDirection(0, width / 2) + topLeft;

  /// 转换成圆角矩形
  /// [RRect]
  toRRect(double radius) =>
      RRect.fromRectAndRadius(this, Radius.circular(radius));

  /// [toRRect]
  toRRectFromRadius(Radius radius) => RRect.fromRectAndRadius(this, radius);

  /// [toRRect]
  toRRectFromXY(double radiusX, double radiusY) =>
      RRect.fromRectXY(this, radiusX, radiusY);
}

//endregion Rect 扩展

//region Size 扩展

extension SizeEx on Size {
  Rect toRect([Offset? offset]) => (offset ?? Offset.zero) & this;
}

//endregion Size 扩展

/// https://pub.dev/packages/date_format
/*extension DateTimeEx on DateTime {
  toFormatString() {
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(this);
  }
}*/
