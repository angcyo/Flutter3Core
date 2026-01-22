part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/10
///
/// io操作相关, 密集操作相关.
///
/// 被执行的方法需要是静态的, 并且使用`@pragma('vm:entry-point')`注释,
/// 运行在[Isolate]中, 可以执行耗时操作.
///
/// [compute] 会创建一个新的[Isolate]来执行[callback]. 内部使用[Isolate.run]执行.
///
/// ```
/// import 'dart:isolate';
///
/// void main() async {
///   // 启动一个 isolate 来处理计算
///   final receivePort = ReceivePort();
///   await Isolate.spawn(heavyComputation, receivePort.sendPort);
///
///   // 监听来自新的 Isolate 的消息
///   receivePort.listen((message) {
///     print('Received from isolate: $message');
///     // 关闭 ReceivePort
///     receivePort.close();
///   });
/// }
///
/// // 重载 Isolate 执行的函数
/// void heavyComputation(SendPort sendPort) {
///   // 进行一些耗时操作
///   int result = 0;
///   for (int i = 0; i < 10;0000; i++) {
///     result += i;
///   }
///   // 给主 isolate 发送结果
///   sendPort.send(result);
/// }
/// ```
///
/// # isolate_manager: ^6.1.2
///
/// https://pub.dev/packages/isolate_manager
///
/// # worker_manager: ^7.2.7
///
/// https://pub.dev/packages/worker_manager

//region 性能

/// 定义一个常量, 当图片像素字节数据大于这个值时, 建议使用[flutterCompute]
const kIsolateComputePixelsSize = 1024 * 1024 * 10;

/// 定义一个常量, 当图片字节数据大于这个值时, 建议使用[flutterCompute]
const kIsolateComputeBytesSize = 1024 * 1024 * 1;

/// # 并发
/// https://dart.cn/guides/language/concurrency
///
/// # Isolate 的工作原理
/// https://dart.cn/guides/language/concurrency#how-isolates-work
///
/// # io计算
/// [compute] 会创建一个新的[Isolate]来执行[callback]. 内部使用[Isolate.run]执行.
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
/// # io中操作的数据必须通过参数的方式传入/传出, 否则会报错.
///
/// `Illegal argument in isolate message: object is unsendable`
///
/// # 示例
///
/// ```
/// List<int> _createTestData(int length) {
///   final bytes = bytesWriter((writer) {
///     writer.writeFillHex(length: length);
///   });
///   return bytes;
/// }
///
/// final bytes = await io(size, _createTestData);
/// ```
///
/// [Completer]
/// - [compute] 内部也是[Isolate.run]回调函数就是多了一个入参
///
/// ```
/// 在 Flutter 2.15 中，工作隔离区可以调用 Isolate.exit() ，并将结果作为参数传递。
/// Dart 运行时会将包含结果的内存从工作隔离区传递给主隔离区，而无需复制，
/// 主隔离区可以在恒定时间内接收到结果。
/// 我们在 Flutter 2.8 中更新了 compute() 实用函数，以利用 Isolate.exit() 的特性。
/// 如果您已经在使用 compute() ，那么升级到 Flutter 2.8 后，您将自动获得这些性能提升。
/// ```
/// - [Isolate.exit]
/// https://blog.dart.dev/dart-2-15-7e7a598e508a
Future<R> io<M, R>(
  M message,
  @pragma('vm:entry-point') ComputeCallback<M, R> callback, {
  String? debugLabel,
}) => compute(
  callback,
  message,
  debugLabel: debugLabel ?? "io-${nowTimeString()}",
);

/// 在[Isolate]中运行, [callback]可以直接访问上下文的数据(能够send的数据), 不需要主动send
/// - [SendPort.send]
/// https://www.youtube.com/watch?v=PPwJ75vqP_s&list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG&index=2
/// ```
/// final data = await run(() => jsonDecode(jsonString));
/// ```
///
/// ```
/// Invalid argument(s): Illegal argument in isolate message:
/// object is unsendable - Library:'dart:async'
/// Class: _AsyncCompleter@4048458
/// (see restrictions listed at `SendPort.send()` documentation for more information)
/// Isolate._spawnFunction (dart:isolate-patch/isolate_patch.dart:398:25)
/// ```
///
/// - [run]
/// - [isolateRun]
///
/// - [Future.sync]
/// - [Isolate.run]
Future<R> run<R>(
  @pragma('vm:entry-point') ResultCallback<R> callback, {
  String? debugName,
}) => Isolate.run(
  () => callback(),
  debugName: debugName ?? "run-${nowTimeString()}",
);

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
/// - [run]
/// - [isolateRun]
///
/// - [Isolate.run]
/// - [Isolate.spawn]
@alias
Future<R> isolateRun<R>(
  @pragma('vm:entry-point') ResultCallback<R> callback, {
  String? debugName,
}) => run(callback, debugName: debugName);

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
