part of '../flutter3_ffi.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/30
///
/// ffi扩展
///
/// [FfiListIntEx]
/// [FfiListDoubleEx]
///
/// [FfiVecUint8Ex]
/// [FfiVecDoubleEx]
extension FfiListIntEx on List<int> {
  /// 转成[Vec_uint8_t]
  /// [StringUtf8Pointer.toNativeUtf8]
  ///
  /// [malloc]
  /// [calloc]
  ffi.Pointer<Vec_uint8_t> toVecUint8() {
    final bytes = this;
    //创建一个指针, 用来ffi传递
    final ffi.Pointer<ffi.Uint8> bytesPtr = calloc<ffi.Uint8>(bytes.length);
    final Uint8List nativeBytes = bytesPtr.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);

    //ffi传递的结构体
    final ptr = calloc<Vec_uint8_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;
    return ptr;
  }

  /// 转成[Vec_uint8_t], 并自动释放内存
  R? withVecUint8<R>(R? Function(ffi.Pointer<Vec_uint8_t> ptr) action) {
    Stopwatch? watch;
    if (kDebugMode) {
      watch = Stopwatch()..start();
    }
    final bytes = this;
    //创建一个指针, 用来ffi传递
    //分配内存: 55ms
    final ffi.Pointer<ffi.Uint8> bytesPtr = calloc<ffi.Uint8>(bytes.length);
    final Uint8List nativeBytes = bytesPtr.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);

    //ffi传递的结构体
    final ptr = calloc<Vec_uint8_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;

    try {
      watch?.stop();
      if (kDebugMode) {
        debugPrint('分配内存: ${watch?.elapsedMilliseconds}ms');
      }
      Stopwatch? watch2;
      if (kDebugMode) {
        watch2 = Stopwatch()..start();
      }
      //执行耗时: 4688ms
      final result = action(ptr);
      watch2?.stop();
      if (kDebugMode) {
        debugPrint('执行耗时: ${watch2?.elapsedMilliseconds}ms');
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

/// [FfiListIntEx]
/// [FfiListDoubleEx]
///
/// [FfiVecUint8Ex]
/// [FfiVecDoubleEx]
extension FfiVecUint8Ex on Vec_uint8_t {
  /// 转成字节
  Uint8List toBytes() {
    final result = ptr;
    final reversedBytes = result.asTypedList(len);
    //debugger();
    //calloc.free(result);释放内存之后, 数据会变成脏数据
    return reversedBytes;
  }

  /// rgba像素字节数据转成图片
  Future<ui.Image> toImageFromPixels(int width, int height,
      [ui.PixelFormat format = ui.PixelFormat.rgba8888]) {
    final bytes = toBytes();
    //debugger();
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      format,
      completer.complete,
    );
    return completer.future;
  }

  /// 转成字符串
  /// [Utf8Pointer.toDartString]
  String toStr() => utf8.decode(toBytes());

  /// [toStr]
  /// [Utf8Pointer.toDartString]
  String toUtf8() => toStr();
}

/// [FfiListIntEx]
/// [FfiListDoubleEx]
///
/// [FfiVecUint8Ex]
/// [FfiVecDoubleEx]
extension FfiListDoubleEx on List<double> {
  /// 转成[Vec_float_t]
  ffi.Pointer<Vec_float_t> toVecFloat() {
    final bytes = this;
    //创建一个指针, 用来ffi传递
    final ffi.Pointer<ffi.Float> bytesPtr = calloc<ffi.Float>(bytes.length);
    final Float32List nativeBytes = bytesPtr.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);
    //ffi传递的结构体
    final ptr = calloc<Vec_float_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;
    return ptr;
  }

  /// 转成[Vec_double_t]
  ffi.Pointer<Vec_double_t> toVecDouble() {
    final bytes = this;
    //创建一个指针, 用来ffi传递
    final ffi.Pointer<ffi.Double> bytesPtr = calloc<ffi.Double>(bytes.length);
    final Float64List nativeBytes = bytesPtr.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);
    //ffi传递的结构体
    final ptr = calloc<Vec_double_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;
    return ptr;
  }

  //--

  /// 自动释放内存
  /// [toVecDouble]
  R? withVecDouble<R>(R? Function(ffi.Pointer<Vec_double_t> ptr) action) {
    final ptr = toVecDouble();
    try {
      return action(ptr);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } finally {
      calloc.free(ptr.ref.ptr);
      calloc.free(ptr);
    }
  }

  /// 自动释放内存
  /// [toVecFloat]
  R? withVecFloat<R>(R? Function(ffi.Pointer<Vec_float_t> ptr) action) {
    final ptr = toVecFloat();
    try {
      return action(ptr);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } finally {
      calloc.free(ptr.ref.ptr);
      calloc.free(ptr);
    }
  }
}

extension FfiVecFloatEx on Vec_float_t {
  /// 转成列表[Float32List]
  ///
  /// ```
  /// 此方法调用多次会崩溃...
  /// Abort message: 'Scudo ERROR: corrupted chunk header at address 0x200007a2a3f87b0'
  /// ```
  Float32List toFloatList() {
    final result = ptr;
    final reversedBytes = result.asTypedList(len);
    try {
      return Float32List.fromList(reversedBytes);
    } finally {
      calloc.free(result);
    }
  }
}

extension FfiVecDoubleEx on Vec_double_t {
  /// 转成列表[Float64List]
  ///
  /// ```
  /// 此方法调用多次会崩溃...
  /// Abort message: 'Scudo ERROR: corrupted chunk header at address 0x200007a2a3f87b0'
  /// ```
  Float64List toDoubleList() {
    final result = ptr;
    final reversedBytes = result.asTypedList(len);
    try {
      return Float64List.fromList(reversedBytes);
    } finally {
      calloc.free(result);
    }
  }
}

/// 二维数据列表扩展
extension FfiListListDoubleEx on List<List<double>> {
  /// 转成[Vec_Vec_double_t]
  ffi.Pointer<Vec_Vec_double_t> toVecVecDouble() {
    final bytes = this;
    //创建一个指针, 用来ffi传递
    final ffi.Pointer<Vec_double_t> bytesPtr =
        calloc<Vec_double_t>(bytes.length);

    for (var i = 0; i < bytes.length; i++) {
      final list = bytes[i];
      //list.toVecDouble()
      final ref = list.toVecDouble().ref;
      bytesPtr[i] = ref;
      //bytesPtr.elementAt(i);
      //bytesPtr += ref;
    }

    //ffi传递的结构体
    final ptr = calloc<Vec_Vec_double_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;
    return ptr;

    /*final bytes = this;

    int refLen = 0;
    int refMxLen = 0;
    final refList = <Vec_double>[];
    for (var i = 0; i < bytes.length; i++) {
      final list = bytes[i];
      final ref = list.toVecDouble().ref;
      refList.add(ref);
      refLen += ref.len;
      refMxLen = ref.len > refMxLen ? ref.len : refMxLen;
    }
    refLen = refMxLen * bytes.length;

    debugger();

    //创建一个指针, 用来ffi传递
    final ffi.Pointer<Vec_double_t> bytesPtr =
        calloc<Vec_double_t>(refMxLen);
    for (var i = 0; i < refList.length; i++) {
      final ref = refList[i];
      bytesPtr[i] = ref;
    }

    debugger();

    //ffi传递的结构体
    final ptr = calloc<Vec_Vec_double_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = refLen;
    ptr.ref.cap = refLen;

    debugger();
    return ptr;*/
  }

  /// 自动释放内存
  R? withVecVecDouble<R>(
      R? Function(ffi.Pointer<Vec_Vec_double_t> ptr) action) {
    final ptr = toVecVecDouble();
    try {
      return action(ptr);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } finally {
      calloc.free(ptr);
    }
  }
}

extension FfiVecVecDoubleEx on Vec_Vec_double_t {
  /// 类型反转
  List<Float64List> toDoubleListList() {
    final result = <Float64List>[];
    for (var i = 0; i < len; i++) {
      //debugger();
      final sub = ptr[i];
      result.add(sub.toDoubleList());

      /*final list = sub.ptr.asTypedList(sub.len);
      result.add(list);*/
      //final list = ptr.ref.ptr[i];
      //result.add(list.toDoubleList());
    }
    return result;
  }
}

extension FfiStringEx on String {

  /// 转成[Vec_uint8_t]
  Vec_uint8_t toVecUint8() {
    final bytes = utf8.encode(this);
    final ffi.Pointer<ffi.Uint8> bytesPtr = calloc<ffi.Uint8>(bytes.length);
    final Uint8List nativeBytes = bytesPtr.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);
    //ffi传递的结构体
    final ptr = calloc<Vec_uint8_t>();
    ptr.ref.ptr = bytesPtr;
    ptr.ref.len = bytes.length;
    ptr.ref.cap = bytes.length;
    return ptr.ref;
  }
  
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
  Future<ui.Image> toImage([ui.PixelFormat format = ui.PixelFormat.rgba8888]) =>
      pixels.toImageFromPixels(w, h, format);
}

/// 批量创建[Vec_uint8_t]指针
R? ffiPtrList<R>(
  R? Function(List<ffi.Pointer<Vec_uint8_t>> ptrList) action,
  List<dynamic> args,
) {
  final ptrList = <ffi.Pointer<Vec_uint8_t>>[];
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg is String) {
      ptrList.add(utf8.encode(arg).toVecUint8());
    } else if (arg is List<int>) {
      ptrList.add(arg.toVecUint8());
    } else if (arg is ffi.Pointer<Vec_uint8_t>) {
      ptrList.add(arg);
    } else {
      assert(() {
        print("无法处理的类型: [${arg.runtimeType}]");
        return true;
      }());
    }
  }
  try {
    return action(ptrList);
  } catch (e, s) {
    assert(() {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: e,
          stack: s /*?? StackTrace.current*/,
        ),
        forceReport: true,
      );
      return true;
    }());
  } finally {
    for (final element in ptrList) {
      calloc.free(element.ref.ptr);
      calloc.free(element);
    }
  }
  return null;
}

/// 批量创建[Vec_double_t]指针
R? ffiPtrDoubleList<R>(
  R? Function(List<ffi.Pointer<Vec_double_t>> ptrList) action,
  List<dynamic> args,
) {
  final ptrList = <ffi.Pointer<Vec_double_t>>[];
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg is List<double>) {
      ptrList.add(arg.toVecDouble());
    } else if (arg is ffi.Pointer<Vec_double_t>) {
      ptrList.add(arg);
    } else {
      assert(() {
        print("无法处理的类型: [${arg.runtimeType}]");
        return true;
      }());
    }
  }
  try {
    return action(ptrList);
  } catch (e, s) {
    assert(() {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(
          exception: e,
          stack: s /*?? StackTrace.current*/,
        ),
        forceReport: true,
      );
      return true;
    }());
  } finally {
    for (final element in ptrList) {
      calloc.free(element.ref.ptr);
      calloc.free(element);
    }
  }
  return null;
}
