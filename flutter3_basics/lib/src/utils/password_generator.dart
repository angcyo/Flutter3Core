part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/11
///
/// 随机生成密码
class PasswordGenerator {
  PasswordGenerator._();

  static final Random _random = Random.secure();

  /// 根据正则表达式生成密码
  ///
  /// # 使用示例
  /// - 至少包含一个小写字母
  /// - 至少包含一个大写字母
  /// - 至少包含一个数字
  /// - 至少包含一个特殊字符
  /// - 长度为 8～16 位
  /// ```
  /// final password = PasswordGenerator.generate(
  ///   length: 12,
  ///   pattern: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,16}$',
  /// );
  ///
  /// print(password);
  /// ```
  ///
  /// [pattern] 密码规则
  /// [length] 密码长度
  /// [maxAttempts] 最大尝试次数
  static String? generate({
    required String pattern,
    int length = 12,
    int maxAttempts = 10000,
  }) {
    const chars =
        'abcdefghijklmnopqrstuvwxyz'
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        '0123456789'
        '!@#\$%^&*()_+-=[]{};:,.?';

    final regex = RegExp(pattern);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final password = List.generate(
        length,
        (_) => chars[_random.nextInt(chars.length)],
      ).join();

      if (regex.hasMatch(password)) {
        return password;
      }
    }

    //throw Exception('无法生成符合规则的密码，请检查正则表达式');
    return null;
  }
}
