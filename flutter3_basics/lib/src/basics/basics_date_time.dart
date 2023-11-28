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
  String format([String? newPattern = "yyyy-MM-dd HH:mm:ss"]) {
    DateFormat dateFormat = DateFormat();
    return dateFormat.format(this);
  }
}
