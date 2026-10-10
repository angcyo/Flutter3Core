///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/10
///
/// dart 语法测试
///
/// https://dart.dev/
void main() {
  print("Hello Dart!");
  final result1 = _testFunction();
  //final result2 = _testFunction2();
  print("$result1"); // null
}

/// null
dynamic _testFunction() {}

/// Error: This expression has type 'void' and can't be used.
void _testFunction2() {}
