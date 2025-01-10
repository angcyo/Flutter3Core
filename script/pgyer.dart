import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/16
///
/// 蒲公英上传脚本
/// https://www.pgyer.com/doc/view/api#fastUploadApp

/// 片蒲公英官网地址
const host = "https://www.pgyer.com";

/// 蒲公英接口地址
const apiBase = "https://www.pgyer.com/apiv2/app";

void main(List<String> arguments) async {
  final currentPath = Directory.current.path;
  colorLog('[pgyer]工作路径->$currentPath');

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");
  //print(yaml);

  final apiKey = localYaml?["pgyer_api_key"] ?? yaml?["pgyer_api_key"];
  if (apiKey == null) {
    throw "请在根目录的[script.yaml]或[script.local.yaml]文件中配置蒲公英[pgyer_api_key]";
  }

  //是否要使用飞书的webhook通知
  final useFeishuWebhook =
      localYaml["use_feishu_webhook"] ?? yaml["use_feishu_webhook"];

  //上传成功的数量
  int count = 0;
  for (final folder
      in (localYaml?["pgyer_path"] ?? yaml?["pgyer_path"] ?? [])) {
    final fileList = await _getFileList(folder);
    if (fileList.isEmpty) {
      continue;
    }
    colorLog('开始上传文件夹->$folder');
    final length = fileList.length;
    var index = 0;
    for (final file in fileList) {
      final filePath = file.path;
      colorLog('开始上传文件->$filePath');
      try {
        final buildType = filePath.endsWith(".apk")
            ? "android"
            : filePath.endsWith(".ipa")
                ? "ios"
                : null;
        if (buildType != null) {
          final versionMap = await _getVersionDes(folder);
          final tokenText = await _getCOSToken(apiKey, buildType,
              buildUpdateDescription: versionMap?["versionDes"]);

          final tokenJson = jsonDecode(tokenText);
          final succeed = await _uploadAppFile(tokenJson["data"], file);
          if (succeed) {
            count++;
            await _writeUploadRecord(folder, file);
            final url =
                await _checkAppIsPublish(apiKey, tokenJson["data"]["key"]);
            if (useFeishuWebhook != false &&
                index == length - 1 &&
                url != null) {
              //只在最后一个文件上传成功之后, 进行飞书webhook通知
              final webhook =
                  localYaml["feishu_webhook"] ?? yaml["feishu_webhook"];
              final logUrl =
                  localYaml["change_log_url"] ?? yaml["change_log_url"];
              await _sendFeishuWebhook(
                webhook,
                _assembleVersionTitle(versionMap),
                versionMap?["versionDes"],
                linkUrl: url,
                changeLogUrl: logUrl,
              );
            }
          }
        } else {
          colorLog("不支持的文件->$filePath");
        }
      } catch (e, s) {
        colorLog(s.toString());
        colorLog(e);
      }
      index++;
    }
  }

  //await _checkAppIsPublish(apiKey, "123");
}

/// 获取指定目录下需要上传的文件列表
Future<List<File>> _getFileList(String folder) async {
  final result = <File>[];
  final dir = Directory(folder);
  if (await dir.exists()) {
    final recordText = await _readUploadRecord(folder);
    final files = dir.listSync();
    for (final file in files) {
      if (file is File) {
        final fileName = p.basename(file.path);
        if (fileName.endsWith(".apk") || fileName.endsWith(".ipa")) {
          final record =
              "$fileName/${file.lastModifiedSync().millisecondsSinceEpoch}";
          if (recordText.contains(record)) {
            colorLog("跳过上传->$fileName");
            continue;
          }
          result.add(file);
        }
      }
    }
  }
  return result;
}

/// 在指定文件夹下, 读取上传记录内容
Future<String> _readUploadRecord(String folder) async {
  try {
    final uploadRecordFile = File("$folder/.upload");
    return uploadRecordFile.readAsStringSync();
  } catch (e) {
    return "";
  }
}

/// 写入指定记录
Future _writeUploadRecord(String folder, File file) async {
  final uploadRecordFile = File("$folder/.upload");
  if (!uploadRecordFile.existsSync()) {
    uploadRecordFile.parent.createSync(recursive: true);
    uploadRecordFile.createSync();
  }
  final fileName = p.basename(file.path);
  final record =
      "$fileName/${file.lastModifiedSync().millisecondsSinceEpoch}\n";
  await uploadRecordFile.writeAsString(record, mode: FileMode.append);
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

//---

/// 获取上传的token
///
///  [buildType]
/// (必填) 需要上传的应用类型，如果是iOS类型请传 ios或ipa
/// 如果是Android类型请传 android apk
///
Future<String> _getCOSToken(
  String apiKey,
  String buildType, {
  String? buildDescription,
  String? buildUpdateDescription,
}) async {
  const api = "$apiBase/getCOSToken";
  //post请求
  final postBody = {
    "_api_key": apiKey,
    "buildType": buildType,
    "buildInstallType": 1.toString(),
    "buildInstallDate": 2.toString(),
    "buildDescription": buildDescription,
    "buildUpdateDescription": buildUpdateDescription,
  }.removeAllNull();
  final response = await http.post(Uri.parse(api),
      body: postBody,
      headers: {"Content-Type": "application/x-www-form-urlencoded"});
  final body = response.body;
  print(body);
  return body;
}

/// 上传文件到第上一步获取的 URL
Future<bool> _uploadAppFile(dynamic tokenData, File file) async {
  final api = "${tokenData["endpoint"]}";
  //post请求 form-data 类型

  // 创建一个 MultipartRequest
  final request = http.MultipartRequest('POST', Uri.parse(api));

  // 添加 form-data 字段
  request.fields["key"] = tokenData["params"]["key"];
  request.fields["signature"] = tokenData["params"]["signature"];
  request.fields["x-cos-security-token"] =
      tokenData["params"]["x-cos-security-token"];

  // 添加文件字段
  final filePart = await http.MultipartFile.fromPath('file', file.path);
  request.files.add(filePart);

  // 发送请求并获取响应
  final response = await request.send();

  // 读取响应内容
  final responseBody = await response.stream.bytesToString();

  print(responseBody);
  if (response.statusCode == 204) {
    colorLog("上传成功->${file.path}");
  }
  return response.statusCode == 204;
}

/// 检查应用是否发布
/// 如果返回 code = 1246 ，可间隔 3s ~ 5s 重新调用 URL 进行检测，直到返回成功或失败。
/// @return url下载页
Future _checkAppIsPublish(String apiKey, String buildKey) async {
  const api = "$apiBase/buildInfo";
  //get请求
  final response = await http.get(Uri.parse(api).replace(queryParameters: {
    "_api_key": apiKey,
    "buildKey": buildKey,
  }));
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)?["data"];
    final buildShortcutUrl = data?["buildShortcutUrl"];
    if (buildShortcutUrl != null) {
      final url = "$host/$buildShortcutUrl";
      colorLog("\n应用发布成功->$url\n${data["buildQRCodeURL"]}");
      return url;
    } else {
      //延迟3秒, 继续查询
      colorLog('请稍等...');
      await Future.delayed(const Duration(seconds: 3));
      return await _checkAppIsPublish(apiKey, buildKey);
    }
  }
  return null;
}

extension MapEx<K, V> on Map<K, V> {
  /// 遍历移除所有value为null的key
  Map<K, V> removeAllNull([bool copy = false]) {
    final map = copy ? Map.from(this) : this;
    final keys = <K>[];
    map.forEach((key, value) {
      if (value == null) {
        keys.add(key);
      }
    });
    keys.forEach(map.remove);
    return map as Map<K, V>;
  }
}

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

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}
