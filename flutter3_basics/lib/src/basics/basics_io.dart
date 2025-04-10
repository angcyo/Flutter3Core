part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/10
///
/// io操作相关, 密集操作相关
///

//region 性能

/// 定义一个常量, 当图片像素字节数据大于这个值时, 建议使用[flutterCompute]
const kIsolateComputePixelsSize = 1024 * 1024 * 10;

/// 定义一个常量, 当图片字节数据大于这个值时, 建议使用[flutterCompute]
const kIsolateComputeBytesSize = 1024 * 1024 * 1;

/// 并发
/// https://dart.cn/guides/language/concurrency
///
/// Isolate 的工作原理
/// https://dart.cn/guides/language/concurrency#how-isolates-work
///
/// io计算
/// [compute] 会创建一个新的[Isolate]来执行[callback]
/// https://pub.dev/documentation/compute/latest/compute/compute-constant.html
///
/// ```
/// https://isar.dev/zh/recipes/multi_isolate.html#%E4%BE%8B%E5%AD%90
/// // 创建一个新的 isolate，写入 10000 条讯息到数据库
/// compute(createDummyMessages, 10000).then(() {
///   print('isolate finished');
/// });
/// ```
///
/// io中操作的数据必须通过参数的方式传入/传出, 否则会报错.
///
/// `Illegal argument in isolate message: object is unsendable`
///
/// [Completer]
Future<R> io<M, R>(M message, ComputeCallback<M, R> callback) =>
    compute(callback, message, debugLabel: "io-${nowTimeString()}");

/// 在[Isolate]中运行, [callback]可以直接访问上下文的数据(能够send的数据), 不需要主动send
/// [SendPort.send]
/// https://www.youtube.com/watch?v=PPwJ75vqP_s&list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG&index=2
/// ```
/// final data = await run(() => jsonDecode(jsonString));
/// ```
/// ```
/// Invalid argument(s): Illegal argument in isolate message:
/// object is unsendable - Library:'dart:async'
/// Class: _AsyncCompleter@4048458
/// (see restrictions listed at `SendPort.send()` documentation for more information)
/// Isolate._spawnFunction (dart:isolate-patch/isolate_patch.dart:398:25)
/// ```
/// [Future.sync]
Future<R> run<R>(ResultCallback<R> callback) {
  return Isolate.run(() => callback(), debugName: "run-${nowTimeString()}");
}

/// 内存隔离, 不共享. 只能传递基础数据类型, 或者可以被`send`的对象
/// [SendPort.send]
///
/// 请尽量在静态方法中调用此方法.
///
/// ```
/// Invalid argument(s): Illegal argument in isolate message:
/// object is unsendable - Library:'dart:isolate' Class:
/// _Timer@1026248 (see restrictions listed at `SendPort.send()`
/// documentation for more information)
/// ```
///
/// [Isolate.run]
/// [Isolate.spawn]
Future<R> isolateRun<R>(ResultCallback<R> callback) => run(callback);

///
/// https://santhosh-adiga-u.medium.com/multithreading-in-flutter-238aa63e29bd
/// ```dart
/// import 'dart:async';
/// import 'package:flutter/foundation.dart';
///
/// void main() async {
///   final result = await ComputeService.compute(fibonacci, 40);
///   print('Fibonacci result: $result');
/// }
///
/// int fibonacci(int n) {
///   if (n == 0 || n == 1) {
///     return n;
///   }
///   return fibonacci(n - 1) + fibonacci(n - 2);
/// }
///
/// class ComputeService {
///   static Future<dynamic> compute(Function function, dynamic arg) async {
///     final response = Completer<dynamic>();
///
///     final isolate = await Isolate.spawn(_spawnIsolate);
///
///     final sendPort = ReceivePort();
///     isolate.addOnExitListener(sendPort.sendPort);
///     isolate.ping(sendPort.sendPort);
///
///     sendPort.listen((message) {
///       if (message is SendPort) {
///         message.send(arg);
///       } else {
///         response.complete(message);
///       }
///     });
///
///     return response.future;
///   }
///
///   static void _spawnIsolate(SendPort sendPort) {
///     final receivePort = ReceivePort();
///
///     sendPort.send(receivePort.sendPort);
///
///     receivePort.listen((message) {
///       final result = Function.apply(message, [40]);
///       sendPort.send(result);
///     });
///   }/
/// }
/// ```

//endregion 性能
