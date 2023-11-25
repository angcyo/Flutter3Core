part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///

/// 创建字符串
String stringBuffer(void Function(StringBuffer builder) action) {
  StringBuffer stringBuffer = StringBuffer();
  action(stringBuffer);
  return stringBuffer.toString();
}

String stringBuilder(void Function(StringBuilder builder) action) {
  StringBuilder builder = StringBuilder();
  action(builder);
  return builder.toString();
}

class StringBuilder {
  StringBuffer stringBuffer = StringBuffer();

  void write(Object? object) {
    stringBuffer.write(object);
  }

  void writeln([Object? obj = ""]) {
    stringBuffer.writeln(obj);
  }

  StringBuilder append(
    Object? object, [
    Object? object2,
    Object? object3,
    Object? object4,
    Object? object6,
    Object? object7,
    Object? object8,
    Object? object9,
  ]) {
    stringBuffer.write(object);
    if (object2 != null) {
      stringBuffer.write(object2);
    }
    if (object3 != null) {
      stringBuffer.write(object3);
    }
    if (object4 != null) {
      stringBuffer.write(object4);
    }
    if (object6 != null) {
      stringBuffer.write(object6);
    }
    if (object7 != null) {
      stringBuffer.write(object7);
    }
    if (object8 != null) {
      stringBuffer.write(object8);
    }
    if (object9 != null) {
      stringBuffer.write(object9);
    }
    return this;
  }

  StringBuilder appendLine(
    Object? object, [
    Object? object2,
    Object? object3,
    Object? object4,
    Object? object6,
    Object? object7,
    Object? object8,
    Object? object9,
  ]) {
    stringBuffer.writeln(object);
    if (object2 != null) {
      stringBuffer.writeln(object2);
    }
    if (object3 != null) {
      stringBuffer.writeln(object3);
    }
    if (object4 != null) {
      stringBuffer.writeln(object4);
    }
    if (object6 != null) {
      stringBuffer.writeln(object6);
    }
    if (object7 != null) {
      stringBuffer.writeln(object7);
    }
    if (object8 != null) {
      stringBuffer.writeln(object8);
    }
    if (object9 != null) {
      stringBuffer.writeln(object9);
    }
    return this;
  }

  StringBuilder newLine() {
    stringBuffer.writeln();
    return this;
  }

  void appendAll(msg) {
    msg.toString().split('\n').forEach((element) {
      stringBuffer.writeln(element);
    });
  }

  @override
  String toString() {
    return stringBuffer.toString();
  }
}
