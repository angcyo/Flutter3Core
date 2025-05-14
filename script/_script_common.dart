import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/12
///
/// 脚本基础方法
///
/// emoji : https://getemoji.com/
///
/// 当前脚本运行的路径
String get currentPath => Directory.current.path;

/// 输出带颜色的日志
void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

/// 输出带颜色的错误日志
void colorErrorLog(dynamic msg, [int col = 9]) {
  print('\x1B[38;5;${col}m$msg');
}

/// 确保文件夹存在
void ensureFolder(String? folderPath) {
  if (folderPath == null || folderPath.isEmpty) {
    return;
  }
  Directory(folderPath).createSync(recursive: true);
}

//---

/// 执行命令
Future runCommand(
  String executable, {
  String? dir,
  List<String>? args,
}) async {
  final result = Process.runSync(
    executable,
    [...?args],
    runInShell: true,
    workingDirectory: dir ?? currentPath,
  );
  colorLog(result.stdout, 250); //输出标准输出
}

//---

dynamic _localYaml;
dynamic _yaml;

/// 获取脚本`script.local.yaml`和`script.yaml`配置文件中配置的值
dynamic getScriptYamlValue(String key) {
  if (_localYaml == null) {
    final localYamlFile = File("$currentPath/script.local.yaml");
    _localYaml = loadYaml(
        localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  }

  if (_yaml == null) {
    final yamlFile = File("$currentPath/script.yaml");
    _yaml = loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");
  }

  return _localYaml?[key] ?? _yaml?[key];
}

/// [getScriptYamlValue]的别名
dynamic $value(String key) {
  return getScriptYamlValue(key);
}

/// 获取列表配置
List? $list(String key) {
  final value = $value(key);
  if (value is List) {
    return value;
  }
  return null;
}

//--

/// 发送飞书webhook消息 - 富文本消息
/// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot
///
/// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot#f62e72d5
Future sendFeishuWebhookPost(
  String? webhook,
  String? title,
  String? text, {
  String? linkUrl,
  String? changeLogUrl,
  bool atAll = true,
}) async {
  if (webhook == null) {
    colorLog("未指定飞书webhook, 不发送消息");
    return;
  }
  //post请求
  final postBody = {
    "msg_type": "post",
    "content": {
      "post": {
        "zh_cn": {
          "title": title,
          "content": [
            [
              if (text != null) ...[
                {"tag": "text", "text": text},
                {"tag": "text", "text": "\n"},
              ],
              if (linkUrl != null) ...[
                {"tag": "text", "text": "\n"},
                {"tag": "a", "text": "点击查看/下载", "href": linkUrl}
              ],
              if (changeLogUrl != null) ...[
                {"tag": "text", "text": "\n"},
                {"tag": "a", "text": "查看更新记录", "href": changeLogUrl}
              ],
              if (atAll) ...[
                {"tag": "text", "text": "\n"},
                {"tag": "at", "user_id": "all"}
              ],
            ]
          ]
        }
      }
    },
  };
  final response = await http.post(Uri.parse(webhook),
      body: jsonEncode(postBody),
      headers: {"Content-Type": "application/json"});
  print(response.body);
}

/// 发送飞书webhook消息 - 卡片消息
/// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot#478cb64f
///
/// 卡片样式编辑:
/// https://open.feishu.cn/cardkit
///
Future sendFeishuWebhookInteractive(
  String? webhook,
  String? title,
  String? text, {
  String? subTitle,
  String? linkUrl,
  String? changeLogUrl,
  bool atAll = true,
}) async {
  if (webhook == null) {
    colorErrorLog("未指定飞书webhook, 不发送消息!");
    return;
  }
  //post请求
  final postBody = {
    "msg_type": "interactive",
    "card": {
      "schema": "2.0",
      "config": {
        "update_multi": true,
        "style": {
          "text_size": {
            "normal_v2": {
              "default": "normal",
              "pc": "normal",
              "mobile": "heading"
            }
          }
        }
      },
      "header": title == null
          ? null
          : {
              "title": {"tag": "plain_text", "content": title},
              "subtitle": {"tag": "plain_text", "content": subTitle},
              "template": "blue",
              // blue wathet turquoise green yellow orange red carmine violet purple indigo grey default
              "padding": "12px 12px 12px 12px"
            },
      "body": {
        "direction": "vertical",
        "padding": "12px 12px 12px 12px",
        "elements": [
          if (text != null)
            {
              "tag": "markdown",
              "content": text,
              "text_align": "left",
              "text_size": "normal_v2",
              "margin": "0px 0px 0px 0px"
            },
          if (changeLogUrl != null)
            {
              "tag": "button",
              "text": {"tag": "plain_text", "content": "查看更新记录"},
              "type": "default",
              "width": "default",
              "size": "medium",
              "behaviors": [
                {
                  "type": "open_url",
                  "default_url": changeLogUrl,
                  "pc_url": "",
                  "ios_url": "",
                  "android_url": ""
                }
              ],
              "margin": "0px 0px 0px 0px"
            },
          if (linkUrl != null)
            {
              "tag": "button",
              "text": {"tag": "plain_text", "content": "点击查看/下载"},
              "type": "primary_filled",
              "width": "default",
              "size": "medium",
              "behaviors": [
                {
                  "type": "open_url",
                  "default_url": linkUrl,
                  "pc_url": "",
                  "ios_url": "",
                  "android_url": ""
                }
              ],
              "margin": "0px 0px 0px 0px"
            },
          if (atAll)
            {
              "tag": "div",
              "text": {"content": "<at id=all></at>", "tag": "lark_md"}
            }
        ]
      }
    },
  };
  final response = await http.post(Uri.parse(webhook),
      body: jsonEncode(postBody),
      headers: {"Content-Type": "application/json"});
  print(response.body);
}
