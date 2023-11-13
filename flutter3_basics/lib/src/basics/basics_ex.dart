part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//const kDebugMode = bool.fromEnvironment("dart.vm.product") == false;
/// 默认的小数点后几位
const kDefaultDigits = 2;

/// 一天的毫秒数
const kDay = 24 * 60 * 60 * kSecond;

/// 一小时的毫秒数
const kHour = 60 * 60 * kSecond;

/// 一分钟的毫秒数
const kMinute = 60 * kSecond;

/// 一秒的毫秒数
const kSecond = 1000;

//region Object 扩展

extension ObjectEx on Object {
  /// [Object]的hash值
  String hash() => hashCode.toRadixString(16);

  /// [Object]的hash值
  String classHash() => "$runtimeType(${hash()})";
}

//endregion Object 扩展

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

  /// 返回#ff00ff00
  String toHexColor([bool leadingHashSign = true]) =>
      toHex(leadingHashSign: leadingHashSign);

  /// 判断当前颜色是否是暗色
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.dark;

  /// 判断当前颜色是否是亮色
  bool get isLight =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light;
}

//endregion Color 扩展

//region String 扩展

typedef StringEachCallback = void Function(String element);
typedef StringIndexEachCallback = void Function(int index, String element);

extension StringEx on String {
  /// 字符串转换成int
  int toInt({int? radix}) => int.parse(this, radix: radix);

  /// 字符串转换成int
  int? toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// 字符转换成Color对象
  Color toColor() => ColorEx.fromHex(this);

  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  DateTime toDateTime() => DateTime.parse(this);

  /// [Uri]
  Uri toUri() => Uri.parse(this);

  /// 确保前缀是指定的字符串
  /// 返回新的字符串
  String ensurePrefix(String prefix) {
    if (!startsWith(prefix)) {
      return '$prefix$this';
    }
    return this;
  }

  /// 确保后缀
  /// 返回新的字符串
  String ensureSuffix(String suffix) {
    if (!endsWith(suffix)) {
      return '$this$suffix';
    }
    return this;
  }

  /// 遍历字符串, 不带索引
  forEach(StringEachCallback callback) {
    for (var i = 0; i < length; i++) {
      callback(this[i]);
    }
  }

  /// 遍历字符串, 带索引
  forEachIndex(StringIndexEachCallback callback) {
    for (var i = 0; i < length; i++) {
      callback(i, this[i]);
    }
  }

  /// 遍历字符串, 不带索引
  forEachByChars(StringEachCallback callback) {
    for (var element in characters) {
      callback(element);
    }
  }

  /// 遍历字符串, 带索引
  forEachIndexByChars(StringIndexEachCallback callback) {
    var index = 0;
    for (var element in characters) {
      callback(index++, element);
    }
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

//region Int 扩展

extension NumEx on num {
  /// 保留小数点后几位
  /// [digits] 小数点后几位
  /// [removeZero] 是否移除小数点后面的0
  /// [ensureInt] 如果是整数, 是否优先使用整数格式输出
  /// ```
  /// 8.10 -> 8.1   //removeZero
  /// 8.00 -> 8     //removeZero or ensureInt
  /// 8.10 -> 8.10  //ensureInt
  /// ```
  String toDigits({
    int digits = kDefaultDigits,
    bool removeZero = true,
    bool ensureInt = false,
  }) {
    if (ensureInt) {
      if (this is int) {
        return toString();
      } else {
        var int = toInt();
        if (this == int) {
          return int.toString();
        }
      }
    }

    // 直接转出来的字符串, 会有小数点后面的0
    var value = toStringAsFixed(digits);
    // 去掉小数点后面的0
    if (value.contains('.')) {
      while (value.endsWith('0')) {
        value = value.substring(0, value.length - 1);
      }
      if (value.endsWith('.')) {
        value = value.substring(0, value.length - 1);
      }
    }
    return value;
  }

  /// 在两个数字之间线性插值，通过 b外推因子 t。
  /// [progress] [0~1]
  /// [lerpDouble]
  num lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }
}

//endregion Int 扩展

//region Int 扩展

extension IntEx on int {
  /// 转换成颜色
  /// [Color]
  Color toColor() => Color(this);

  /// 将13位毫秒时间, 拆成对应的
  /// 0:多少毫秒
  /// 1:多少秒
  /// 2:多少分
  /// 3:多少小时
  /// 4:多少天
  List<int> toPartTimes() {
    var list = <int>[];
    var time = this;
    var day = time ~/ kDay;
    time = time % kDay;
    var hour = time ~/ kHour;
    time = time % kHour;
    var minute = time ~/ kMinute;
    time = time % kMinute;
    var second = time ~/ kSecond;
    time = time % kSecond;
    var millisecond = time;
    list.add(millisecond);
    list.add(second);
    list.add(minute);
    list.add(hour);
    list.add(day);
    return list;
  }
}

//endregion Int 扩展

/// https://pub.dev/packages/date_format
/*extension DateTimeEx on DateTime {
  toFormatString() {
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(this);
  }
}*/
