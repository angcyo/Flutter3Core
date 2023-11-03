part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///

/// 创建字符串
String stringBuilder(void Function(StringBuffer builder) action) {
  StringBuffer stringBuffer = StringBuffer();
  action(stringBuffer);
  return stringBuffer.toString();
}

class StringBuilder {
  StringBuffer stringBuffer = StringBuffer();

  StringBuilder append(Object? object) {
    stringBuffer.write(object);
    return this;
  }

  StringBuilder appendLine(Object? object) {
    stringBuffer.writeln(object);
    return this;
  }

  StringBuilder newLine() {
    stringBuffer.writeln();
    return this;
  }

  @override
  String toString() {
    return stringBuffer.toString();
  }
}
