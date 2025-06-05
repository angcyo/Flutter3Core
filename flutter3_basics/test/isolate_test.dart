import 'dart:isolate';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/05
///
void main() async {
  // 获取当前 Isolate
  print('Main Isolate Name: ${Isolate.current.debugName}');

  // 使用 compute 函数创建新的 Isolate
  //await compute(isolateFunction, 'Hello from main isolate!');
}
