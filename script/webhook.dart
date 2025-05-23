import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/16
///
/// Webhook
void main(List<String> arguments) async {
  /*final currentPath = Directory.current.path;
  print('工作路径->$currentPath');
  final yamlFile = File("$currentPath/script.yaml");
  print('配置文件路径->${yamlFile.path}');

  final yaml = loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");
  final webhook = yaml["feishu_webhook"];*/
  //---
  //_sendFeishuText(webhook, "text");

  await _sendFeishuVersion();
  //await _sendLP5xVersion("E:/AndroidProjects/LaserPeckerRNPro/android/.apk");
  /*await _sendLP5xVersion(
      "/Users/angcyo/project/android/laserpecker-rn-pro/android/.apk/");*/
}

/// LP版本发布通知
Future _sendLP5xVersion(
  String versionFilePath, {
  String? versionDes,
}) async {
  final currentPath = Directory.current.path;

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");

  final versionMap = await _getVersionDes(versionFilePath);
  _sendFeishuWebhook(
    localYaml?["feishu_webhook_lp5"] ?? yaml?["feishu_webhook_lp5"],
    _assembleVersionTitle(versionMap),
    versionDes ?? versionMap?["versionDes"],
    linkUrl: "https://www.pgyer.com/PNbc",
    changeLogUrl:
        "https://gitee.com/angcyo/file/raw/master/LaserPeckerPro/change.json",
  );
}

//--

/// 组装版本发布通知的标题
String? _assembleVersionTitle(Map<String, dynamic>? json) {
  final versionTitle = json?["versionTitle"]?.toString();
  if (versionTitle != null) {
    return versionTitle;
  }

  final versionDate = json?["versionDate"]?.toString();
  final versionName = json?["versionName"]?.toString();
  final versionCode = json?["versionCode"]?.toString();

  StringBuffer buffer = StringBuffer();
  if (versionDate != null) {
    buffer.write("$versionDate ");
  }
  buffer.write("新版本发布");
  if (versionName != null) {
    //版本名
    buffer.write(" V$versionName");
    if (versionCode != null) {
      //版本号
      buffer.write("($versionCode)");
    }
  }
  return buffer.toString();
}

//--

/// 发送[version.json]飞书发布通知
Future _sendFeishuVersion({
  String? versionDes,
  String? linkUrl,
  String? changeLogUrl,
}) async {
  final currentPath = Directory.current.path;

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml = loadYaml(yamlFile.readAsStringSync());

  for (final folder in (localYaml["pgyer_path"] ?? yaml["pgyer_path"])) {
    final versionMap = await _getVersionDes(folder);
    _sendFeishuWebhook(
      localYaml["feishu_webhook"] ?? yaml["feishu_webhook"],
      _assembleVersionTitle(versionMap),
      versionDes ?? versionMap?["versionDes"],
      linkUrl: linkUrl ??
          versionMap?["downloadUrl"] ??
          versionMap?["versionUrl"] ??
          versionMap?["url"],
      changeLogUrl: changeLogUrl ?? versionMap?["changeLogUrl"],
    );
  }
}

//---

/// 发送飞书webhook消息
/// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot
Future _sendFeishuText(
  String webhook,
  String? text, {
  bool atAll = true,
}) async {
  //post请求
  final postBody = {
    "msg_type": "text",
    "content": {
      "text": '''${atAll ? "<at user_id=\"all\">所有人</at>" : ""}$text'''
    },
  };
  final response = await http.post(Uri.parse(webhook),
      body: jsonEncode(postBody),
      headers: {"Content-Type": "application/json"});
  print(response.body);
}

/// 发送飞书webhook消息
/// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot
Future _sendFeishuWebhook(
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
                {"tag": "a", "text": "更新记录", "href": changeLogUrl}
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

/// 在指定文件夹下, 读取版本更新数据
Future<Map<String, dynamic>?> _getVersionDes(String folder) async {
  try {
    final file = File("$folder/version.json");
    final text = file.readAsStringSync();
    return jsonDecode(text);
  } catch (e) {
    return null;
  }
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}
