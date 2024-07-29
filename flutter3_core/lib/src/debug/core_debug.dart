part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/10
///

/// 返回是否要拦截默认处理
typedef DebugCommandAction = bool Function(DebugCommand);

/// 调试指令信息
/// ```
/// @key#int=value
/// ```
class DebugCommand {
  final String command;

  final String key;
  final String type;
  final String value;

  DebugCommand(
    this.command,
    this.key,
    this.type,
    this.value,
  );
}

class CoreDebug {
  static List<DebugCommandAction> debugCommandActionList =
      <DebugCommandAction>[];

  /// 解析 @key#type=value 格式
  static (String? key, String? type, dynamic value) parseHiveKey(String line) {
    final keyIndex = line.indexOf("@");
    final typeIndex = line.indexOf("#");
    final valueIndex = line.indexOf("=");

    //result
    String? resultKey, resultType;
    dynamic resultValue;

    if (keyIndex != -1 && typeIndex != -1 && valueIndex != -1) {
      //@key#int=value
      String key = line.substring(keyIndex + 1, typeIndex);
      final type = line.substring(typeIndex + 1, valueIndex);
      final valueString = line.substring(valueIndex + 1, line.length);

      //---

      if (key.isNotEmpty) {
        key = key.toLowerCase();
        resultKey = key;
        switch (key) {
          default:
            //@key#int=value
            switch (type) {
              case "b":
              case "bool":
              case "boolean":
                resultType = "b";
                final value = valueString.toBoolOrNull();
                resultValue = value;
                break;
              case "int":
              case "i":
              case "long":
              case "l":
                resultType = "i";
                final value = valueString.toIntOrNull();
                resultValue = value;
                break;
              case "float":
              case "f":
              case "double":
              case "d":
                resultType = "d";
                final value = valueString.toDoubleOrNull();
                resultValue = value;
                break;
              case "string":
              case "s":
                resultType = "s";
                resultValue = valueString;
                break;
            }
            break;
        }
      }
    }

    return (resultKey, resultType, resultValue);
  }

  /// [HiveEx]
  /// [HiveStringEx]
  static void parseHiveKeys(List<String?>? lines, [BuildContext? context]) {
    context ??= GlobalConfig.def.globalContext;
    if (lines == null) {
      return;
    }
    bool match = false;
    try {
      for (var line in lines) {
        if (line == null) {
          continue;
        }

        final keyIndex = line.indexOf("@");
        final typeIndex = line.indexOf("#");
        final valueIndex = line.indexOf("=");

        if (keyIndex != -1 && typeIndex != -1 && valueIndex != -1) {
          //@key#int=value
          String key = line.substring(keyIndex + 1, typeIndex);
          final type = line.substring(typeIndex + 1, valueIndex);
          final valueString = line.substring(valueIndex + 1, line.length);

          bool intercept = false;
          try {
            for (var action in debugCommandActionList) {
              intercept = intercept ||
                  action.call(DebugCommand(line, key, type, valueString));
            }
            if (intercept) {
              match = true;
            }
          } catch (e) {
            assert(() {
              l.e(e);
              return true;
            }());
          }

          //---

          if (!intercept && key.isNotEmpty) {
            key = key.toLowerCase();
            switch (key) {
              case "cmd":
                switch (type) {
                  case "clear":
                    //删除hawk的键
                    //@cmd#clear=key
                    valueString.hiveDelete();
                    match = true;
                    break;
                }
                break;
              default:
                //@key#int=value
                switch (type) {
                  case "b":
                  case "bool":
                  case "boolean":
                    final value = valueString.toBoolOrNull();
                    if (value == null) {
                      key.hiveDelete();
                    } else {
                      key.hivePut(value);
                    }
                    match = true;
                    break;
                  case "int":
                  case "i":
                  case "long":
                  case "l":
                    final value = valueString.toIntOrNull();
                    if (value == null) {
                      key.hiveDelete();
                    } else {
                      key.hivePut(value);
                    }
                    match = true;
                    break;
                  case "float":
                  case "f":
                  case "double":
                  case "d":
                    final value = valueString.toDoubleOrNull();
                    if (value == null) {
                      key.hiveDelete();
                    } else {
                      key.hivePut(value);
                    }
                    match = true;
                    break;
                  case "string":
                  case "s":
                    key.hivePut(valueString);
                    match = true;
                    break;
                }
                break;
            }
          }
        }
      }
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }

    if (match) {
      //震动反馈
      if (context != null) {
        Feedback.forLongPress(context);
      }
    }
  }
}
