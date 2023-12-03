import 'package:intl/intl.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///

///
/// https://pub.dev/packages/date_format
/// https://pub.dev/packages/intl
/// [NumberFormat]
/// [DateFormat]
/// [BidiFormatter]
/// [nowTime]
/// [nowTimeString]
extension DateTimeEx on DateTime {
  /// 格式化时间 `2023-11-04 10:13:40.083`
  String format([String? newPattern = "yyyy-MM-dd HH:mm:ss", String? locale]) {
    DateFormat dateFormat = DateFormat(newPattern, locale);
    return dateFormat.format(this);
  }
}

extension TimeEx on int {
  /// 格式化时间 `2023-11-04 10:13:40.083`
  String format([String? newPattern = "yyyy-MM-dd HH:mm:ss"]) {
    return DateTime.fromMillisecondsSinceEpoch(this).format(newPattern);
  }
}
