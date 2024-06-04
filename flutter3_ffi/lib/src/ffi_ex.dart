part of '../flutter3_ffi.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/30
///
/// ffi扩展
extension FfiListIntEx on List<int> {
  /// 转成[Vec_uint8_t], 并自动释放内存
  R? withVecUint8<R>(R? Function(ffi.Pointer<Vec_uint8_t> ptr) action) {
    final watch = Stopwatch()..start();
    final bytes = this;
    //创建一个指针, 用来ffi传递
    //分配内存: 55ms
    final ffi.Pointer<ffi.Uint8> bytesPtr =
        calloc.allocate<ffi.Uint8>(bytes.length);
    final Uint8List nativeBytes = bytesPtr.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);

    //ffi传递的结构体
    final ptr = calloc<Vec_uint8_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;

    try {
      watch.stop();
      if (kDebugMode) {
        debugPrint('分配内存: ${watch.elapsedMilliseconds}ms');
      }
      final watch2 = Stopwatch()..start();
      //执行耗时: 4688ms
      final result = action(ptr);
      watch2.stop();
      if (kDebugMode) {
        debugPrint('执行耗时: ${watch2.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } finally {
      calloc.free(bytesPtr);
      calloc.free(ptr);
    }
  }
}

extension FfiVecUint8Ex on Vec_uint8_t {
  /// 转成字节
  Uint8List toBytes() {
    final result = ptr;
    final reversedBytes = result.asTypedList(len);
    return reversedBytes;
  }

  /// 转成字符串
  String toStr() => utf8.decode(toBytes());
}

extension FfiStringEx on String {
  /// [FfiListIntEx.withVecUint8]
  /// [nullptr]
  R? withVecUint8<R>(R? Function(ffi.Pointer<Vec_uint8_t> ptr) action) {
    //转成字节, 这是必须的
    final bytes = utf8.encode(this);
    return bytes.withVecUint8(action);
  }
}

extension FfiPixelsImageEx on PixelsImage {
  /// 转成图片
  Future<ui.Image> toImage(int width, int height,
      [ui.PixelFormat format = ui.PixelFormat.rgba8888]) {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels.toBytes(),
      width,
      height,
      format,
      completer.complete,
    );
    return completer.future;
  }
}
