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
  await Isolate.spawn(isolateFunction, 'Hello from main isolate!');

  //等待
  await Future.delayed(Duration(seconds: 1));
}

void isolateFunction(String message) {
  print('Isolate Name: ${Isolate.current.debugName}');
  print(message);
}
