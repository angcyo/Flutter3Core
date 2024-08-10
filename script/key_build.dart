import 'dart:convert';
import 'dart:math';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/08/06
///
void main() {
  decodeAccKey(encodeAccKey(30));
  //YW5nY3lvOTQ0NjY2Mjg2NDEzNzE3MjMwMzE1MjIyODI1MzQyODQ1NDc3NjQy
}

/// 加密生成acc key
/// [day] 多少天
String encodeAccKey(int day) {
  final timestamp =
      DateTime.now().add(Duration(days: day)).millisecondsSinceEpoch;
  final nowtime = DateTime.now().millisecondsSinceEpoch;

  //前13个字符
  final before = randomString(13);
  //后13个字符
  final after = randomString(13);
  const k = "angcyo";
  final key = '$k$before$timestamp$after${randomString(9)}';
  //转成base64
  String base64 = base64Encode(utf8.encode(key));

  //将前6个字符移到到尾部
  base64 = base64.substring(6) + base64.substring(0, 6);
  colorLog("[$day]天[$timestamp]->$base64");
  /*final nowtime = DateTime.now().millisecondsSinceEpoch;
  colorLog(nowtime);
  colorLog(timestamp);
  colorLog(timestamp - nowtime);
  colorLog(randomString(5));
  colorLog(randomString(1));
  colorLog(randomString(13));*/

  return base64;
}

/// 解密生成的acc key
void decodeAccKey(String key) {
  key = key.substring(key.length - 6) + key.substring(0, key.length - 6);

  final decode = utf8.decode(base64Decode(key));
  colorLog(decode);
  final timestampString = decode.substring(19, 19 + 13);
  colorLog(timestampString);
  final nowtime = DateTime.now().millisecondsSinceEpoch;
  final timestamp = int.parse(timestampString);

  final hours = const Duration(hours: 1).inMilliseconds;
  if (nowtime > timestamp) {
    colorLog('已过期:${(nowtime - timestamp) ~/ hours}h');
  } else {
    colorLog('还剩:${(timestamp - nowtime) ~/ hours}h');
  }
}

//--

///产生指定长度的随机
String randomString(int length) {
  final random = Random();
  /*final codeUnits = List.generate(length, (index) {
    return random.nextInt(26) + 65;
  });
  return String.fromCharCodes(codeUnits);*/
  //随机数字
  return List.generate(length, (index) {
    return random.nextInt(10);
  }).join();
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}
