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
  testAccountRegExp("123456");
  testAccountRegExp("1234567");
  testAccountRegExp("a12345");
  testAccountRegExp("a123456");
  testAccountRegExp("A1234567");
  testAccountRegExp("abcdef");
  testAccountRegExp("abcde6");
  testAccountRegExp("account");
  testAccountRegExp("acco unt");
  testPasswordRegExp("123456");
  testPasswordRegExp("password");
  testPasswordRegExp("account!!_!@#%TY&U");
  testPasswordRegExp("!!account!!_!@#%^TY&U");
  //RegExp
  testRegExp();
}

void testAccountRegExp(String account) {
  print("$account -> ${account.isValidAccount()}");
}

void testPasswordRegExp(String password) {
  print("$password -> ${password.isValidPassword()}");
}

/// 测试正则
void testRegExp() {
  final regExp = RegExp(r'[-_]');
  print("Laserabc_G01-38754E".split(r'[-_]'));
  print("Laserabc_G01-38754E".split(regExp));
  print("Laserabc_G01".split(regExp));
  print("G01".split(regExp));
  print("G01-38754E".split(regExp));
}
