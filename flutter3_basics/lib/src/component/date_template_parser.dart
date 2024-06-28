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
    for (var i = 0; i < text.length; i++) {
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
  final calendar = DateTime.now();

  /// 替换的资源, 国际化
  Map<String, String?>? replaceVariableMap;

  DateTemplateParser() {
    templateList.add("weekday");
    templateList.add("dayOfYear");
    templateList.add("weekOfYear");

    replaceVariableAction = (variable) {
      return replaceVariableMap == null
          ? variable
          : replaceVariableMap?[variable];
      /*switch (variable) {
      "year" -> _string(R.string.lib_year)
      "month" -> _string(R.string.lib_month)
      "day" -> _string(R.string.lib_day)
      "hour" -> _string(R.string.lib_hour)
      "minute" -> _string(R.string.lib_minute)
      "second" -> _string(R.string.lib_second)
      "millisecond" -> _string(R.string.lib_millisecond)
      "am" -> _string(R.string.lib_am)
      "pm" -> _string(R.string.lib_pm)
      else -> null
      }*/
    };

    replaceTemplateAction = (template) {
      switch (template) {
        case "yyyy":
        case "YYYY":
          return "${calendar.year}";
        case "yy":
        case "YY":
          return "${calendar.year}".substring(2);
        default:
          return template;
      }
    };
  }
}

extension NumberTemplateEx on String {
  /// 解析数字模板
  String parseNumberTemplate(String number) {
    return NumberTemplateParser().parse(number, this);
  }
}
