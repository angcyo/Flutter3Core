import 'dart:convert';
import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/05/12
///
/// 发送邮件
void main() async {
  //--
  //await brevoSendEmail("angcyo@126.com", "123456");
  //await brevoSendEmail("angcyoo@gmail.com", "123456");
  //--
  await resendSendEmail("angcyo@126.com", "123456");
  //await resendSendEmail("angcyoo@gmail.com", "123456");
  print("...");
}

/// 创建邮箱内容
String createEmailContent(String code) {
  final htmlContent = File(
    'test/LaserabcLightEmailTemplateEn.html',
  ).readAsStringSync();
  return htmlContent.replaceAll('{{code}}', code);
}

Future brevoSendEmail(
  String toEmail,
  String code, {
  String subject = "验证码",
  String? toEmailName,
}) async {
  const url = "https://api.brevo.com/v3/smtp/email";
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(url));
  request.headers.add(
    "api-key",
    "",
  );
  request.add(
    {
      "htmlContent": createEmailContent(code),
      "sender": {"email": "no-reply@laserabc.com", "name": "no-reply"},
      "subject": subject,
      "to": [
        {"email": toEmail, "name": toEmailName ?? toEmail},
      ],
    }.toJsonString().bytes,
  );
  final response = await request.close();
  final body = await response.transform(const Utf8Decoder()).join();
  //{"messageId":"<202605120940.84018092551@smtp-relay.mailin.fr>"}
  print(body);
  client.close();
}

Future resendSendEmail(
  String toEmail,
  String code, {
  String subject = "验证码",
}) async {
  const url = "https://api.resend.com/emails";
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(url));
  request.headers.add(
    "Authorization",
    "",
  );
  request.add(
    {
      "from": "no-reply<no-reply@laserabc.com>",
      "to": [toEmail],
      "subject": subject,
      "html": createEmailContent(code),
    }.toJsonString().bytes,
  );
  final response = await request.close();
  final body = await response.transform(const Utf8Decoder()).join();
  //{"id":"c1634760-1951-45a3-b0eb-77095ab62eb2"}
  print(body);
  client.close();
}
