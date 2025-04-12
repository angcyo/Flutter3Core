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
/// localazy_feishu_webhook: xxx
/// localazy_write_key: xxx
/// localazy_read_key: xxx
/// localazy_download_folder: .output/.download
/// localazy_upload_folder: /Users/angcyo/project/android/UICoreDemo/.apk/Android_LDS/中文
/// localazy_upload_files:
///   - "**.xml"
/// ```
///
void main(List<String> arguments) async {
  // 是否要执行下载
  final doDownload = false;
  // 是否要执行上传
  final doUpload = true;
  // webhook
  final doWebhook = true;

  colorLog('[localazy]工作路径->$currentPath');
  //await runCommand("localazy", args: ["list"]);

  final lang = $value("localazy_upload_lang") ?? "zh-Hans-CN";
  final uploadFiles = $list("localazy_upload_files");

  final configOutput = "$currentPath/.output/localazy.json";
  _configLocalazyJson({
    "writeKey": $value("localazy_write_key"),
    "readKey": $value("localazy_read_key"),
    "upload": {
      "type": $value("localazy_upload_type") ?? "android",
      "folder": $value("localazy_upload_folder"),
      "files": uploadFiles == null
          ? {
              "pattern": $value("localazy_upload_pattern") ?? "**.xml",
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
      "folder": $value("localazy_download_folder"),
      "files": {
        "output": $value("localazy_download_output") ?? r"${lang}/${file}",
      }
    }
  }, configOutput);

  //--
  if (doDownload) {
    ensureFolder($value("localazy_download_folder"));

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

    if (doWebhook) {
      final webhook = $value("localazy_feishu_webhook");
      await sendFeishuWebhookInteractive(
        webhook,
        "🫡 localazy(lds-app-android)",
        "✌️ Android 上传了资源文件, 请注意查收!",
        linkUrl: "https://localazy.com/p/lds-app-android/files",
        atAll: false,
      );
    }
  }
}

/// 将参数写入配置json文件, 方便CLI执行.
void _configLocalazyJson(Map config, String output) {
  final json = jsonEncode(config);
  final file = File(output);
  file.writeAsStringSync(json);
}
