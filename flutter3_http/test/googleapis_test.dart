import 'dart:convert';
import 'dart:io';

import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/05/12
///
/// # 更轻松地访问 Google API
///
/// https://developers.google.com/api-client-library?hl=zh-cn
///
/// # 通过 Java 轻松访问 Google API
///
/// https://developers.google.com/api-client-library/java?hl=zh-cn
///
/// # googleapis: ^16.0.0
///
/// https://pub.dev/packages/googleapis
///
void main() async {
  print("当前路径->${Directory.current.path}");
  await GmailSender(await createGmailApi()).sendEmail(
    to: "angcyo@126.com",
    subject: "Test!",
    body: "${DateTime.now()}",
  );
}

Future<GmailApi> createGmailApi() async {
  // 1. 加载下载的 JSON 密钥文件
  final jsonCredentials = File(
    'test/angcyo-google-key.temp.json',
  ).readAsStringSync();
  final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);

  // 2. 定义所需的作用域 (Gmail 发送权限)
  final scopes = [GmailApi.gmailSendScope];

  // 3. 获取认证的 HTTP 客户端
  // 注意：如果是个人账号且没有全域授权，这里需要处理用户授权逻辑
  // 这里演示的是标准的服务账号客户端获取方式
  AuthClient client = await clientViaServiceAccount(credentials, scopes);

  final gmailApi = GmailApi(client);
  return gmailApi;
}

class GmailSender {
  final GmailApi gmailApi;

  GmailSender(this.gmailApi);

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // 1. 构建符合 RFC 2822 标准的字符串
    final messageContent = [
      'From: "Your Name" <me>', // 'me' 是 Gmail API 的特殊别名
      'To: $to',
      'Subject: $subject',
      'Content-Type: text/html; charset="utf-8"',
      '',
      body,
    ].join('\n');

    // 2. Base64Url 编码 (必须去除填充符号 '=')
    final encodedMessage = base64Url
        .encode(utf8.encode(messageContent))
        .replaceAll('=', '');

    final message = Message()..raw = encodedMessage;

    // 3. 调用 API 发送邮件
    try {
      await gmailApi.users.messages.send(message, 'me');
      print('邮件发送成功！');
    } catch (e) {
      //DetailedApiRequestError(status: 400, message: Precondition check failed.)
      print('发送失败: $e');
    }
  }
}
