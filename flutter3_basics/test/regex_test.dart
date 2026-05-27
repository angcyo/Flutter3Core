import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/04/24
///
/// 正则表达式测试
void main() {
  print(
    "你好，{name}！你的积分是 {score}".replaceAllVariable({
      "name": "angcyo",
      "score": "100",
    }),
  );
  //你好，angcyo！你的积分是 100
  print("...");
  print("account".isValidAccount());
  print("acco unt".isValidAccount());
  print("123456".isValidPassword());
  print("password".isValidPassword());
  print("account!!_!@#%TY&U".isValidPassword());
  print("!!account!!_!@#%^TY&U".isValidPassword());
}
