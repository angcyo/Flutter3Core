import 'dart:convert';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/04/10
///
void main() {
  final map = {
    "de": "德语资源数据",
    "en": "英语资源数据",
    "zh": "中文资源数据",
    /* "ja": "日语",
    "ko": "韩语",
    "fr": "法语",
    "es": "西班牙语",
    "it": "意大利语",
    "pt": "葡萄牙语",
    "ru": "俄语",
    "ar": "阿拉伯语",
    "th": "泰语",
    "vi": "越南语",
    "id": "印尼语",
    "ms": "马来语",
    "tr": "土耳其语",*/
  };
  //--
  //final jsonString = json.encoder.convert(map);
  final jsonString = jsonEncode(map);
  print(jsonString);
  //--
  /*final jsonString2 = jsonString.replaceAll("\"", "\\\"");
  print(jsonString2);*/
  final jsonString2 = jsonEncode(jsonString);
  print(jsonString2);
  //--
  //print(json.decoder.convert('"$jsonString2"'));
  print(jsonDecode(jsonString2));
}
