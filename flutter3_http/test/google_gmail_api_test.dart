import 'dart:convert';
import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/05/09
///
/// # Google Gmail API
/// https://developers.google.com/workspace/gmail/api/guides/sending?hl=zh_CN#curl
///
/// ```
/// {
///   "id": "19e0be89148326e9",
///   "threadId": "19e0be89148326e9",
///   "labelIds": [
///     "SENT"
///   ]
/// }
/// ```
///
void main() async {
  const api = "https://gmail.googleapis.com/gmail/v1/users/me/messages/send";
  final accessToken = Platform.environment['google_access_token'];
  const message =
      "From: no-reply@laserabc.com\r\n"
      "To: angcyo@126.com\r\n"
      "Subject: !Test!\r\n"
      "MIME-Version: 1.0\r\n"
      "Content-Type: text/html; charset=utf-8\r\n"
      "\r\n"
      "<html><body><h1>Hello World</h1></body></html>";

  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(api));
  request.headers.add("Authorization", "Bearer $accessToken");
  request.headers.add("Accept", "application/json");
  request.headers.add("Content-Type", "application/json");
  request.add({"raw": message.toBase64}.toJsonString().bytes);

  final response = await request.close();
  final body = await response.transform(const Utf8Decoder()).join();
  print(body);
  client.close();

  print("...");
}
