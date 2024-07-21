import 'dart:io';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/21
///
void main() {
  print(Directory.current.path);

  //final result = Process.runSync("pwd", []);
  //print(result.stdout); // 输出标准输出
  final result = Process.runSync("flutter", ["pub", "get"],
      workingDirectory: Directory.current.path);
  print(result.stdout); // 输出标准输出
  print("...end");
}
