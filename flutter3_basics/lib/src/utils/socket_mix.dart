part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/03
///
/// [ServerSocket] 服务端
/// [Socket] 客户端
mixin SocketMixin {
  /// 连接超时配置
  @configProperty
  Duration? socketConnectTimeoutMixin = Duration(seconds: 5);

  /// 接收数据的回调
  @configProperty
  void Function(Uint8List bytes)? onReceiveDataActionMixin;

  //--

  /// 连上的[Socket]
  @output
  Socket? socketMixin;

  @output
  StreamSubscription<Uint8List>? socketSubscriptionMixin;

  /// 连接服务端
  /// [reconnect] 是否每次都重连, 否则连上后, 就不连接.
  /// [onReceiveAction] 接收到的数据回调, 如果2个都是null, 表示socket结束
  /// @return 连接失败返回null
  @api
  Future<Socket?> connectSocket(
    String host,
    int port, {
    bool reconnect = true,
    Duration? timeout,
    void Function(Uint8List? bytes, Object? error)? onReceiveAction,
  }) async {
    if (!reconnect && socketMixin != null) {
      return socketMixin;
    }
    disconnectSocket();
    try {
      socketMixin = await Socket.connect(
        host,
        port,
        timeout: timeout ?? socketConnectTimeoutMixin,
      );
      socketSubscriptionMixin = socketMixin?.listen(
        (value) {
          onReceiveDataActionMixin?.call(value);
          onReceiveAction?.call(value, null);
        },
        onDone: () {
          assert(() {
            l.i('Socket onDone');
            return true;
          }());
          onReceiveAction?.call(null, null);
          disconnectSocket();
        },
        onError: (e) {
          assert(() {
            l.e('Socket onError->$e');
            return true;
          }());
          onReceiveAction?.call(null, e);
        },
        cancelOnError: true,
      );
      return socketMixin;
    } catch (e) {
      assert(() {
        l.e('Socket connect error->$e');
        return true;
      }());
      onReceiveAction?.call(null, e);
      return null;
    }
  }

  /// 断开连接
  @api
  void disconnectSocket() {
    socketMixin?.close();
    socketMixin?.destroy();
    socketMixin = null;

    socketSubscriptionMixin?.cancel();
    socketSubscriptionMixin = null;
  }

  /// 写入字节数据到[Socket]
  @api
  bool writeSocket(List<int> bytes) {
    if (socketMixin == null) {
      return false;
    }
    try {
      socketMixin?.add(bytes);
      return true;
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
      return false;
    }
  }

//--

  /// 如果在[State]中, 也会触发此方法
  /// ```
  /// dispose() implementations must always call their superclass dispose() method, to ensure that all the resources used by the widget are fully released.
  /// ```
/*void release() {
    disconnectSocket();
  }*/
}
