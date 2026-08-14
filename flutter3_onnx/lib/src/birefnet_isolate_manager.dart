part of '../flutter3_onnx.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/14
///
/// 在一个新的[Isolate]中运行`BiRefNet`模型
/// # 不允许在[Isolate]中运行?
/// ```
/// Bad state: The BackgroundIsolateBinaryMessenger.instance value is invalid until BackgroundIsolateBinaryMessenger.ensureInitialized is executed.
/// ```
/// - [RootIsolateToken.instance]
class BirefnetIsolateManager {
  /// 用于将数据发送至[Isolate]
  SendPort? _sendPort;

  /// 初始化状态
  Future<void>? _initializing;

  /// 初始化方法
  @api
  Future<void> initialize() async {
    if (_sendPort != null) {
      return;
    }

    if (_initializing != null) {
      return _initializing!;
    }

    //WidgetsFlutterBinding.ensureInitialized();
    _initializing = _start();

    try {
      await _initializing!;
    } finally {
      _initializing = null;
    }
  }

  /// 使用模型, 移除图片背景
  /// - [modelPath] 模型所在的路径
  /// - [TransferableTypedData]
  /// # Windows
  /// ```
  /// 耗时->17s895ms
  /// 耗时->12s123ms
  /// 耗时->11s782ms
  /// 耗时->11s799ms
  /// ```
  @api
  Future<UiImage?> removeBackground(
    String? modelPath,
    UiImage? image,
    bool binary,
  ) async {
    if (modelPath?.isFileExistsSync() != true) {
      assert(() {
        l.w("模型文件不存在->$modelPath");
        return true;
      }());
      return image;
    }
    if (image == null) {
      return null;
    }
    await initialize();
    final id = $uuid;
    final completer = Completer<UiImage?>();
    Future<void> handle(String rid, Uint8List? bytes) async {
      if (rid == id) {
        _onHandleReceiveList.remove(handle);
        completer.complete(await bytes?.toImage());
      }
    }

    _onHandleReceiveList.add(handle);
    final data = TransferableTypedData.fromList([(await image.toBytes())!]);
    _sendPort?.send({
      'id': id,
      'modelPath': modelPath,
      'binary': binary,
      'data': data,
    });

    return completer.future;
  }

  /// 释放
  @api
  void dispose() {
    _sendPort?.send(null);
    _sendPort = null;
  }

  //MARK: - method

  /// 处理结果
  final List<Future Function(String id, Uint8List? bytes)>
  _onHandleReceiveList = [];

  /// 启动[Isolate]并初始化[SendPort]
  Future<void> _start() async {
    final completer = Completer<SendPort?>();
    final receivePort = ReceivePort();
    receivePort.listen((message) async {
      // 处理推理请求
      if (message == null) {
        receivePort.close();
      } else if (message is SendPort) {
        _sendPort = message;
        completer.complete(message);
      } else if (message is Map) {
        final String id = message['id'];
        final TransferableTypedData? data = message['data'];
        if (data == null) {
          for (final handle in _onHandleReceiveList.clone()) {
            await handle.call(id, null);
          }
        } else {
          final bytes = data.materialize().asUint8List();
          for (final handle in _onHandleReceiveList.clone()) {
            await handle.call(id, bytes);
          }
        }
      }
    });
    await Isolate.spawn(
      _onnxIsolateEntry,
      IsolateInitData(
        sendPort: receivePort.sendPort,
        rootToken: RootIsolateToken.instance!,
      ),
    );
    await completer.future;
  }
}

class IsolateInitData {
  final SendPort sendPort;
  final RootIsolateToken rootToken;

  IsolateInitData({required this.sendPort, required this.rootToken});
}

/// 当前方法在新的[Isolate]中运行
/// - [ReceivePort.close]
/// - [TransferableTypedData]
@pragma('vm:entry-point')
void _onnxIsolateEntry(IsolateInitData data) {
  final mainSendPort = data.sendPort;
  // 必须最先执行
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootToken);
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);
  // 在这里初始化 ONNX Runtime
  OrtSession? session;
  receivePort.listen((message) async {
    // 处理推理请求
    if (message == null) {
      receivePort.close();
    } else if (message is Map) {
      final String id = message['id'];
      final String modelPath = message['modelPath'];
      final bool binary = message['binary'];
      final TransferableTypedData data = message['data'];
      final bytes = data.materialize().asUint8List();
      //执行算法
      final ort = session ??= await OnnxRuntime().createSession(modelPath);
      try {
        final pngBytes = await BiRefNetHelper.runAsync(
          session: ort,
          binary: binary,
          inputImageBytes: bytes,
        );
        mainSendPort.send({
          'id': id,
          'data': TransferableTypedData.fromList([pngBytes]),
        });
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        mainSendPort.send({'id': id, 'data': null});
      }
    }
  });
}

/// [BirefnetIsolateManager]的实例
@globalInstance
final $birefnetIsolateManager = BirefnetIsolateManager();
