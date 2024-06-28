part of '../../flutter3_basics.dart';

///
/// 数字模板解析器
///
/// `#` 代表数字占位符
/// `,` 代表分隔符
/// `.` 代表小数点
/// `0` 代表补位
/// 其他表示原样输出
///
/// ```
/// #G#,###,000.##
/// ```
///
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/28
class NumberTemplateParser {
  /// 小数点分割符
  String decimalPointChar = '.';

  /// 分隔符集合
  List<String> splitCharList = [','];

  /// 补齐字符集合
  List<String> padCharList = ['0'];

  /// 占位字符集合
  List<String> placeholderCharList = ['#'];

  /// [number] 需要格式化的数字
  /// [template] 模板
  ///
  @callPoint
  String parse(String number, String template) {
    final numberList = number.split(decimalPointChar);
    final intPart = numberList.getOrNull(0)?.reversed; //倒序
    final decimalPart = numberList.getOrNull(1);

    final templateList = template.split(decimalPointChar);
    final intTemplate = templateList.getOrNull(0)?.reversed; //倒序
    final decimalTemplate = templateList.getOrNull(1);

    //整数部分结果
    final intResult = _parseTemplate(intPart, intTemplate).reversed;
    //小数部分结果
    final decimalResult = _parseTemplate(decimalPart, decimalTemplate);

    if (decimalResult.isEmpty || decimalPart == null) {
      return intResult;
    } else {
      return "$intResult$decimalPointChar$decimalResult";
    }
  }

  ///
  String _parseTemplate(String? text, String? template) {
    final result = StringBuffer();
    var templateIndex = 0;
    final length = math.max(text?.length ?? 0, template?.length ?? 0);
    for (var i = 0; i < length; i++) {
      final intChar = text?.getOrNull(i);
      var templateChar = template?.getOrNull(templateIndex);

      if (intChar == null && templateChar == null) {
        break;
      }
      //
      if (intChar == null) {
        //数字不够, 补齐
        while (padCharList.contains(templateChar)) {
          //是补齐符
          result.write(templateChar);
          templateIndex++;
          templateChar = template?.getOrNull(templateIndex);

          if (splitCharList.contains(templateChar)) {
            //是分隔符
            result.write(templateChar);
            while (splitCharList.contains(templateChar)) {
              templateIndex++;
              templateChar = template?.getOrNull(templateIndex);
            }
          }
        }
        break;
      }
      //
      if (templateChar == null) {
        //模板不够, 原样输出
        result.write(intChar);
        continue;
      }
      //
      if (splitCharList.contains(templateChar)) {
        //是分隔符
        result.write(templateChar);
        while (splitCharList.contains(templateChar)) {
          templateIndex++;
          templateChar = template?.getOrNull(templateIndex);
        }
      }

      if (placeholderCharList.contains(templateChar) ||
          padCharList.contains(templateChar)) {
        result.write(intChar);
      } else {
        result.write(templateChar);
      }

      templateIndex++;
    }

    return result.toString();
  }
}

extension NumberTemplateEx on String {
  /// 解析数字模板
  String parseNumberTemplate(String number) {
    return NumberTemplateParser().parse(number, this);
  }
}
