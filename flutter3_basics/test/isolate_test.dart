import 'dart:async';
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
  final map = await Isolate.run(isolateFunction2, debugName: 'isolate2');
  print(map);
  await Isolate.spawn(isolateFunction3, TestDataClass());

  //等待
  await Future.delayed(Duration(seconds: 5));
  print("...end");
}

/// 支持收发
void isolateFunction(String message) {
  print('Isolate Name: ${Isolate.current.debugName}');
  print(message);
}

/// 支持收发
FutureOr<Map<String, dynamic>> isolateFunction2() async {
  print('Isolate Name: ${Isolate.current.debugName}');
  return {
    "name": "angcyo",
    "age": 18,
    "man": true,
    "list": ["1", 1, true],
    "map": {
      "a": "a",
      "1": 1,
      'bool': true,
    }
  };
}

/// 支持收发
void isolateFunction3(TestDataClass message) {
  print('Isolate Name: ${Isolate.current.debugName}');
  print(message);
}

//--

class TestDataClass {
  final String name;
  final int age;
  final bool man;
  final List<dynamic> list;
  final Map<String, dynamic> map;

  TestDataClass({
    this.name = "name",
    this.age = 0,
    this.man = true,
    this.list = const ["1", 1, true],
    this.map = const {
      "a": "a",
      "1": 1,
      'bool': true,
    },
  });

  @override
  String toString() {
    return 'TestDataClass{name: $name, age: $age, man: $man, list: $list, map: $map}';
  }
}
