import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:http/http.dart' as http;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/11/18
///
/// 下载文件测试
void main() async {
  final url =
      "https://raw.githubusercontent.com/dart-lang/shelf/refs/heads/master/pkgs/shelf_static/example/files/favicon.ico";
  final response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;
  //final base64 = bytes.toBase64Image();
  final base64 = bytes.toBase64;
  print(base64);
}
