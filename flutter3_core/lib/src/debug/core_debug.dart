part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/10
///
///
/// 调试指令系统
/// [registerDebugInputValueChanged] 注册一个输入框内容变化通知
/// [CoreDebug.parseHiveKeys] 解析一行一行的字符串, 识别出[DebugCommand]

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

  DebugCommand(this.command, this.key, this.type, this.value);
}

class CoreDebug {
  /// 调试指令[DebugCommand]拦截处理回调
  static List<DebugCommandAction> debugCommandActionList =
      <DebugCommandAction>[];

  /// 解析 @key#type=value 格式返回对应的数据
  /// - [parseHiveKey]
  /// - [parseHiveKeys]
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
        resultKey = key;
        switch (key.toLowerCase()) {
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

  /// hive key 调试处理 @key#type=value
  ///
  /// - @cmd#clear=key : 清除指定键对应的值
  /// - @cmd#show=key : 显示指定键对应的值
  /// - @key#int=value : 设置指定键对应的值
  ///
  /// [HiveEx]
  /// [HiveStringEx]
  ///
  /// - [feedback] 匹配成功是否震动反馈
  ///
  /// - [parseHiveKey]
  /// - [parseHiveKeys]
  ///
  /// @return 有些指令有返回值, 有些没有
  static List<dynamic>? parseHiveKeys(
    List<String?>? lines, {
    BuildContext? context,
    bool? feedback,
  }) {
    context ??= GlobalConfig.def.globalContext;
    if (lines == null || lines.isEmpty) {
      return null;
    }
    List<dynamic>? result = [];
    bool match = false;
    String? lastValueString;
    try {
      for (final line in lines) {
        if (line == null) {
          result.add(null);
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
          lastValueString = valueString;

          bool intercept = false;
          try {
            for (final action in debugCommandActionList) {
              intercept =
                  intercept ||
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
            switch (key.toLowerCase()) {
              case "cmd":
                switch (type) {
                  case "exit": //退出应用
                    $next(() {
                      exitApp();
                    });
                    match = true;
                    result.add(true);
                    break;
                  case "del":
                  case "clear": //删除hawk的键
                    //@cmd#clear=key
                    valueString.hiveDelete();
                    match = true;
                    result.add(true);
                    break;
                  case "get": //获取指定hive的值
                  case "show": //显示hawk的键值
                    //@cmd#show=key
                    final value = switch (null) {
                      _ when valueString == "*" => hiveAll()?.toJsonString(),
                      _ when valueString == "debugInfo" =>
                        DebugPage.buildLastDebugCopyString(
                          GlobalConfig.def.globalContext,
                        ),
                      _ => valueString.hiveGet(),
                    };
                    if (type == "show") {
                      toastBlur(text: value);
                    }
                    match = false;
                    result.add(value);
                    break;
                  case "api": //请求接口
                    () async {
                      final url = valueString.decodeUri();
                      url.get().http(
                        (value, error) {
                          return value;
                        },
                        showErrorToast: false,
                        throwError: false,
                        useDataCodeStatus: false,
                      );
                    }();
                    match = true;
                    result.add(true);
                    break;
                  case "download": //下载并打开文件
                    () async {
                      final downloadUrl = valueString.decodeUri();
                      downloadUrl.download(
                        savePath: await cacheFilePath(
                          downloadUrl.fileName(),
                          "downloads",
                        ),
                        throwError: false,
                        toastError: true,
                        onDownloadAction: (savePath, error) {
                          if (error == null) {
                            //下载成功
                            openFilePath(savePath);
                          }
                        },
                      );
                    }();
                    match = true;
                    result.add(true);
                    break;
                  default:
                    result.add(null);
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
                    result.add(value);
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
                    result.add(value);
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
                    result.add(value);
                    match = true;
                    break;
                  case "string":
                  case "s":
                    key.hivePut(valueString);
                    match = true;
                    result.add(valueString);
                    break;
                }
                break;
            }
          } else {
            result.add(null);
          }
        }
      }
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }

    if (match && feedback == true) {
      //震动反馈
      if (context != null) {
        Feedback.forLongPress(context);
      }
      toastBlur(text: lastValueString);
    }
    return result;
  }
}
