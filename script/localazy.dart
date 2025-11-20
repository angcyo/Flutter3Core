import 'dart:convert';
import 'dart:io';

import '_script_common.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/12
///
/// 国际化资源管理平台
///
/// https://localazy.com/
///
/// https://localazy.com/docs/cli/the-basics
///
/// ## 脚本配置项
///
/// ```
/// localazy:
///   write_key:
///   read_key:
///   feishu_webhook: https://open.feishu.cn/open-apis/bot/v2/hook/7c739dfe-ce69-4525-98c6-ed93579cfe57
///   upload_folder: /Users/angcyo/project/android/UICoreDemo/.apk/Android_LDS/中文
///   upload_files:
///     - "**.xml"
///   download_folder: .output/.download
///   do_download: true
///   do_upload: true
///   do_webhook: true
/// ```
///
void main(List<String> arguments) async {
  colorLog('[localazy]工作路径->$currentPath');
  final config = $value("localazy");
  if (config is! Map) {
    throw "请在根目录的[script.yaml]或[script.local.yaml]文件中配置[localazy]脚本";
  }

  //await runCommand("localazy", args: ["list"]);

  final lang = config["upload_lang"] ?? "zh-Hans-CN";
  final uploadFiles = config["upload_files"];

  // 是否要执行下载
  final doDownload = config["do_download"] == true;
  // 是否要执行上传
  final doUpload = config["do_upload"] == true;
  // webhook
  final doWebhook = config["do_webhook"] == true;

  final configOutput = "$currentPath/.output/localazy.json";
  _configLocalazyJson({
    "writeKey": config["write_key"],
    "readKey": config["read_key"],
    "upload": {
      "type": config["upload_type"] ?? "android",
      "folder": config["upload_folder"],
      "files": uploadFiles == null
          ? {
              "pattern": config["upload_pattern"] ?? "**.xml",
              "lang": lang,
            }
          : [
              for (final file in uploadFiles)
                {
                  "pattern": file,
                  "lang": lang,
                }
            ]
    },
    "download": {
      "folder": config["download_folder"],
      "files": {
        "output": config["download_output"] ?? r"${lang}/${file}",
      }
    }
  }, configOutput);

  //--
  if (doDownload) {
    ensureFolder(config["download_folder"]);

    //执行下载
    await runCommand("localazy", args: [
      "download",
      "-c",
      configOutput,
    ]);
  }

  if (doUpload) {
    //执行上传
    await runCommand("localazy", args: [
      "upload",
      "-c",
      configOutput,
    ]);
  }

  if (doWebhook) {
    final webhook = config["feishu_webhook"]; //feishu_webhook_test
    await sendFeishuWebhookInteractive(
      webhook,
      "🫡 localazy(lds-app-android)",
      "✌️: Android 上传了资源文件, 请注意查收!\n📅: ${DateTime.now()}",
      linkUrl: "https://localazy.com/p/lds-app-android/files",
      atAll: false,
    );
  }
}

/// 将参数写入配置json文件, 方便CLI执行.
void _configLocalazyJson(Map config, String output) {
  final json = jsonEncode(config);
  final file = File(output);
  file.writeAsStringSync(json);
}
