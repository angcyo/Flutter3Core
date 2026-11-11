import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/11
///
void main() {
  final password = PasswordGenerator.generate(
    pattern: '^[a-zA-Z0-9_@#\$!%*?&-]{6,30}\$',
  );



  print(password);
  print("..end");
}
