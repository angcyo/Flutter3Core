import 'dart:convert';

import 'package:flutter3_http/flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/13
///
void main() async {
  final listUrl =
      "https://cdn.jsdelivr.net/gh/mlightcad/cad-data/fonts/fonts.json";
  final string = await listUrl.dioGetString();
  //print(string);
  final jsonArray = jsonDecode(string!);
  for (final json in jsonArray) {
    final file = json["file"];
    final downloadUrl =
        "https://cdn.jsdelivr.net/gh/mlightcad/cad-data/fonts/$file";
    await downloadUrl.download(savePath: "build/shx/$file");
  }
}
