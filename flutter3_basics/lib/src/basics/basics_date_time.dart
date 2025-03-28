part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///

///
/// https://pub.dev/packages/date_format
/// https://pub.dev/packages/jiffy
/// https://pub.dev/packages/intl
/// [NumberFormat]
/// [DateFormat]
/// [BidiFormatter]
/// [nowTimestamp]
/// [nowTimeString]
extension DateTimeEx on DateTime {
  /// 格式化时间 `2023-11-04 10:13:40.083`
  String format([String? newPattern = "yyyy-MM-dd HH:mm:ss", String? locale]) {
    intl.DateFormat dateFormat = intl.DateFormat(newPattern, locale);
    return dateFormat.format(this);
  }

  /// [difference]
  //Duration operator -(DateTime other) => difference(other);

  /// 当前的13位毫秒时间戳
  /// [nowTimestamp]
  int get timestamp => millisecondsSinceEpoch;

  int get dayOfYear {
    final date = DateTime.now();
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  /// 一年中的第几周
  int get weekOfYear {
    final date = DateTime.now();
    final start = DateTime(date.year, 1, 1);
    final days = date.difference(start).inDays;
    return (days ~/ 7) + 1;
  }
}

///
const kMSUnit = ["ms", "s", "m", "h", "d"];
const kMSLTUnit = ["", ":", ":", ":", ":"];
const kSLTUnit = ["", "", ":", ":", ":"];

extension TimeEx on int {
  /// 毫秒转时间对象
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this);

  /// 格式化时间 `2023-11-04 10:13:40.083`
  String format([String? newPattern = "yyyy-MM-dd HH:mm:ss"]) {
    return toDateTime().format(newPattern);
  }

  /// [format]
  String toTimeString([String? newPattern = "yyyy-MM-dd HH:mm:ss"]) =>
      format(newPattern);

  /// 24小时制, 不足2位时, 前面补0
  String to24String(bool is24Hour) {
    final value = toString();
    return is24Hour && value.length < 2 ? "0$value" : value;
  }

  /// 13位时间戳转换成时间字符串, 短时间格式
  /// 转换成刚刚, 几秒前, 几分钟前, 几小时前, 昨天, 前天, 几天前, 几月前, 几年前, 具体时间.
  ///
  /// https://pub.dev/packages/timeago
  ///
  /// moment
  /// [TimeEx.toTimeAgo]
  String toTimeAgo(
      {String just = "刚刚",
      String s = "秒前",
      String m = "分钟前",
      String h = "小时前",
      String d = "天前",
      String yesterday = "昨天",
      String beforeYesterday = "前天",
      String? timePattern = "yyyy-MM-dd HH:mm:ss"}) {
    //10秒之内, 显示刚刚
    final now = nowTimestamp();
    final diff = now - this;
    if (diff < 10 * kSecond) return just;
    //1分钟之内, 显示几秒前
    if (diff < 1 * kMinute) return "$diff$s";
    //1小时之内, 显示几分钟前
    if (diff < 1 * kHour) return "${diff ~/ kMinute}$m";
    //1天之内, 显示几小时前
    if (diff < 1 * kDay) return "${diff ~/ kHour}$h";
    //48小时之内, 显示昨天
    if (diff < 2 * kDay) return yesterday;
    //72小时之内, 显示前天
    if (diff < 3 * kDay) return beforeYesterday;
    //7天之内, 显示几天前
    if (diff < 7 * kDay) return "${diff ~/ kDay}$d";
    return format(timePattern);
  }

  /// 将毫秒转换成, 模板时间
  /// [pattern] 当前位置的值是否要输出显示. 0智能判断 1强制 -1忽略.
  /// [is24Hour] 24小时制
  /// [TimeEx.toPatternTime]
  String toPatternTime({
    List<int> pattern = const [0, 0, 0, 0, 0],
    List<String> unit = kMSUnit,
    bool is24Hour = false,
  }) {
    final times = toPartTimes();
    final ms = times[0];
    final s = times[1];
    final m = times[2];
    final h = times[3];
    final d = times[4];
    return stringBuilder((builder) {
      if (pattern.getOrNull(4) == 1 || (pattern.getOrNull(4) == 0 && d > 0)) {
        builder.write("${d.to24String(is24Hour)}${unit[4]}");
      }
      if (pattern.getOrNull(3) == 1 || (pattern.getOrNull(3) == 0 && h > 0)) {
        builder.write("${h.to24String(is24Hour)}${unit[3]}");
      }
      if (pattern.getOrNull(2) == 1 || (pattern.getOrNull(2) == 0 && m > 0)) {
        builder.write("${m.to24String(is24Hour)}${unit[2]}");
      }
      if (pattern.getOrNull(1) == 1 || (pattern.getOrNull(1) == 0 && s > 0)) {
        builder.write("${s.to24String(is24Hour)}${unit[1]}");
      }
      if (pattern.getOrNull(0) == 1 || (pattern.getOrNull(0) == 0 && ms > 0)) {
        builder.write("${ms.to24String(is24Hour)}${unit[0]}");
      }
    });
    //return "$d天 $h时 $m分 $s秒 $ms毫秒";
  }

  /// 多少m多少s
  String toMSTime({
    List<int> pattern = const [-1, 1, 1, 0, 0],
    List<String> unit = kMSUnit,
    bool is24Hour = false,
  }) {
    return toPatternTime(pattern: pattern, unit: unit, is24Hour: is24Hour);
  }

  /// 多少h多少m多少s
  String toHMSTime({
    List<int> pattern = const [-1, 1, 1, 1, 0],
    List<String> unit = kMSUnit,
    bool is24Hour = false,
  }) {
    return toPatternTime(pattern: pattern, unit: unit, is24Hour: is24Hour);
  }
}
