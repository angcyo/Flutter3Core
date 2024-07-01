part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/28
///
/// 模板解析器,
/// 将字符放在方括号中，即可原样返回而不被格式化替换 (例如， [MM])。
/// YYYY-MM-DD HH:mm:ss
/// https://dayjs.fenxianglu.cn/category/display.html#%E6%A0%BC%E5%BC%8F%E5%8C%96
///
/// ```
/// [YYYYescape] YYYY-MM-DDTHH:mm:ss:SS Z[Z] d dd ZZ A a
/// //YYYYescape 2023-09-02T10:58:27:26 +08:00Z 6 Sa +0800 AM am
/// //YYYYescape 2023-09-02T10:41:24:45 28800000Z 0 Sa 28800000 AM am
/// ```
///
class StringTemplateParser {
  /// 返回需要替换的模板字符串
  String Function(String template) replaceTemplateAction =
      (template) => template;

  /// 返回需要替换的变量字符串
  String? Function(String variable) replaceVariableAction = (variable) => null;

  /// 是否是相同的模板字符
  bool Function(String? before, String after) isSameTemplateCharAction =
      (before, after) {
    if (before == null) {
      return true;
    } else {
      return before == after;
    }
  };

  /// 特殊模板列表, 关键字列表
  /// ```
  /// weekday    //星期几 从0开始, 国际化
  /// dayOfYear  //1年中的第几天 从1开始
  /// weekOfYear //1年中的第几周 从1开始
  /// ```
  ///
  List<String> templateList = [];

  /// 返回值存放
  StringBuffer parseResult = StringBuffer();

  /// 当前解析到char索引
  var index = 0;

  /// 变量开始的字符标识
  String variableStart = "{{";
  String variableEnd = "}}";

  /// 开始解析字符串[text]
  /// [YYYYescape] YYYY-MM-DDTHH:mm:ssZ[Z]
  ///
  @callPoint
  String parse(String text) {
    while (index < text.length) {
      final startIndex = index;
      final variable = findVariable(text, text[index]);
      if (variable != null) {
        final variableStr = replaceVariableAction(variable);
        if (variableStr == null) {
          //没有处理变量, 则忽略变量的处理, 进行下一步模板的处理
          index = startIndex;
        } else {
          parseResult.write(variableStr);
        }
      }

      final template = nextTemplate(text);
      if (template != null) {
        parseResult.write(replaceTemplateAction(template));
      }
      index++;
    }
    return parseResult.toString();
  }

  /// 查找变量表达式
  String? findVariable(String text, String char) {
    if (variableStart.startsWith(char)) {
      final oldIndex = index;
      final startIndex = getNextStringIndex(text, variableStart);
      if (startIndex != -1) {
        index = startIndex + variableStart.length;
        final endIndex = getNextStringIndex(text, variableEnd);
        if (endIndex != -1) {
          index = endIndex + variableEnd.length;
          return text.substring(startIndex + variableStart.length, endIndex);
        }
      }
      index = oldIndex;
    }
    return null;
  }

  int getNextStringIndex(String text, String str) {
    var resultIndex = -1;
    for (var i = index; i < text.length; i++) {
      final endIndex = i + str.length;
      if (endIndex > text.length) {
        break;
      }
      if (text.substring(i, endIndex) == str) {
        resultIndex = i;
        break;
      }
    }
    return resultIndex;
  }

  //--

  /// 下一段需要解析或者需要原样输出的模板
  String? nextTemplate(String text) {
    final oldIndex = index;
    final template = StringBuffer();
    String? lastChar;
    while (index < text.length) {
      final char = text[index];

      final find = findTemplate(text, char);
      if (find != null) {
        //找到了模板
        if (template.isNotEmpty) {
          parseResult.write(replaceTemplateAction(template.toString()));
        }
        return find;
      }

      if (!isSameTemplateChar(lastChar, char)) {
        //不相同的模板字符, 结束
        index = math.max(oldIndex, index - 1);
        return template.toString();
      }

      if (char == '[') {
        //开始解析
        final endIndex = getNextCharIndex(text, ']');
        if (endIndex != -1) {
          //[[xxxMM] 结构
          parseResult.write(text.substring(index + 1, endIndex));
          index = endIndex;
          return null;
        } else {
          //没有找到结束字符],则当做普通字符串处理
          template.write(char);
        }
      } else {
        template.write(char);
      }

      lastChar = char;
      index++;
    }
    return template.toString();
  }

  /// 查找当前字符是否有匹配的模板字符串
  String? findTemplate(String text, String char) {
    for (final template in templateList) {
      if (template.startsWith(char)) {
        final endIndex = index + template.length;
        if (endIndex > text.length) {
          break;
        }
        final target = text.substring(index, endIndex);
        if (target == template) {
          index = endIndex - 1;
          return template;
        }
      }
    }
    return null;
  }

  bool isSameTemplateChar(String? before, String after) {
    return isSameTemplateCharAction(before, after);
  }

  /// 获取下一个指定字符的索引
  int getNextCharIndex(String text, String char) {
    var resultIndex = -1;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == char) {
        resultIndex = i;
        break;
      }
    }
    return resultIndex;
  }
}

/// 日期/时间模板替换
class DateTemplateParser extends StringTemplateParser {
  /// 当前时间
  DateTime calendar = DateTime.now();

  /// 替换的资源, 国际化
  /// ```
  /// "year" -> _string(R.string.lib_year)
  /// "month" -> _string(R.string.lib_month)
  /// "day" -> _string(R.string.lib_day)
  /// "hour" -> _string(R.string.lib_hour)
  /// "minute" -> _string(R.string.lib_minute)
  /// "second" -> _string(R.string.lib_second)
  /// "millisecond" -> _string(R.string.lib_millisecond)
  /// "am" -> _string(R.string.lib_am)
  /// "pm" -> _string(R.string.lib_pm)
  /// else -> null
  Map<String, String?>? replaceVariableMap;

  /// 替换的资源, 国际化
  /// 星期一到星期日
  List<String> weekdayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
        "Sunday",
  ];

  DateTemplateParser() {
    templateList.add("weekday");
    templateList.add("dayOfYear");
    templateList.add("weekOfYear");

    replaceVariableAction = (variable) {
      return replaceVariableMap == null
          ? variable
          : replaceVariableMap?[variable];
    };

    replaceTemplateAction = (template) {
      switch (template) {
        //--
        case "yyyy":
        case "YYYY":
          return "${calendar.year}";
        case "yy":
        case "YY":
          return "${calendar.year}".substring(2);
        //--
        case "M":
          return "${calendar.month}";
        case "MM":
          return "${calendar.month}".padLeft(2, '0');
        //月份英文缩写
        case "MMM":
          return switch (calendar.month) {
            DateTime.january => "Jan", //一月
            DateTime.february => "Feb",
            DateTime.march => "Mar",
            DateTime.april => "Apr",
            DateTime.may => "May",
            DateTime.june => "Jun",
            DateTime.july => "Jul",
            DateTime.august => "Aug",
            DateTime.september => "Sep",
            DateTime.october => "Oct",
            DateTime.november => "Nov",
            DateTime.december => "Dec", //十二月
            _ => "${calendar.month}",
          };
        //月份英文全称
        case "MMMM":
          return switch (calendar.month) {
            DateTime.january => "January", //一月
            DateTime.february => "February",
            DateTime.march => "March",
            DateTime.april => "April",
            DateTime.may => "May",
            DateTime.june => "June",
            DateTime.july => "July",
            DateTime.august => "August",
            DateTime.september => "September",
            DateTime.october => "October",
            DateTime.november => "November",
            DateTime.december => "December", //十二月
            _ => "${calendar.month}",
          };

        //--
        case "D":
          return "${calendar.day}";
        case "DD":
          return "${calendar.day}".padLeft(2, '0');
        //一周中的一天，星期天是 0
        case "d":
          return "${calendar.weekday}";
        //最简写的星期几
        case "dd":
          return switch (calendar.weekday) {
            DateTime.monday => "Mo", //星期一
            DateTime.tuesday => "Tu",
            DateTime.wednesday => "We",
            DateTime.thursday => "Th",
            DateTime.friday => "Fr",
            DateTime.saturday => "Sa",
            DateTime.sunday => "Su", //星期天
            _ => "${calendar.weekday}",
          };

        //简写的星期几
        case "ddd":
          return switch (calendar.weekday) {
            DateTime.monday => "Mon",
            DateTime.tuesday => "Tue",
            DateTime.wednesday => "Wed",
            DateTime.thursday => "Thu",
            DateTime.friday => "Fri",
            DateTime.saturday => "Sat",
            DateTime.sunday => "Sun",
            _ => "${calendar.weekday}"
          };

        //星期几全称
        case "dddd":
          return switch (calendar.weekday) {
            DateTime.monday => "Monday",
            DateTime.tuesday => "Tuesday",
            DateTime.wednesday => "Wednesday",
            DateTime.thursday => "Thursday",
            DateTime.friday => "Friday",
            DateTime.saturday => "Saturday",
            DateTime.sunday => "Sunday",
            _ => "${calendar.weekday}",
          };

        // 星期几国际化
        case "weekday":
          return weekdayList.getOrNull(calendar.weekday - 1) ??
              "${calendar.weekday}";

        //--
        //24小时制
        case "H":
          return "${calendar.hour}";
        case "HH":
          return "${calendar.hour}".padLeft(2, '0');
        case "h":
          return "${calendar.hour % 12}";
        case "hh":
          return "${calendar.hour % 12}".padLeft(2, '0');
        case "m":
          return "${calendar.minute}";
        case "mm":
          return "${calendar.minute}".padLeft(2, '0');
        case "s":
          return "${calendar.second}";
        case "ss":
          return "${calendar.second}".padLeft(2, '0');
        case "S":
          return "${calendar.millisecond}".substring(0, 1);
        case "SS":
          return "${calendar.millisecond}".padLeft(2, '0').substring(0, 2);
        case "SSS":
          return "${calendar.millisecond}".padLeft(3, '0');
        //UTC 的偏移量，±HH:mm
        case "Z":
          final offset = calendar.timeZoneOffset;
          final hours = offset.inHours;
          final minutes = offset.inMinutes % 60;
          return "${hours >= 0 ? '+' : '-'}${hours.abs().toString().padLeft(2, '0')}:${minutes.abs().toString().padLeft(2, '0')}";
        //UTC 的偏移量，±HHmm
        case "ZZ":
          final offset = calendar.timeZoneOffset;
          final hours = offset.inHours;
          final minutes = offset.inMinutes % 60;
          return "${hours >= 0 ? '+' : '-'}${hours.abs().toString().padLeft(2, '0')}${minutes.abs().toString().padLeft(2, '0')}";
        //上午下午
        case "A":
          return calendar.hour < 12 ? "AM" : "PM";
        case "a":
          return calendar.hour < 12 ? "am" : "pm";

        case "dayOfYear":
          return "${calendar.dayOfYear}";

        case "weekOfYear":
          return "${calendar.weekOfYear}";

        //--
        default:
          return template;
      }
    };
  }

  /// 设置当前时间, 指定日期时间
  /// [time] 指定13位时间戳
  void setDate({
    String? date,
    String? datePattern,
    int? time,
  }) {
    if (date != null) {
      calendar = date.toDateTime(datePattern);
    } else if (time != null) {
      calendar = time.toDateTime();
    }
  }
}

extension DateTemplateEx on String {
  /// 解析时间模板
  String parseDateTemplate([void Function(DateTemplateParser parser)? action]) {
    final parser = DateTemplateParser();
    action?.call(parser);
    return parser.parse(this);
  }
}
