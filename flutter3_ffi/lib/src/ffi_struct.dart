part of '../flutter3_ffi.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/30
///

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
final class Vec_uint8 extends ffi.Struct {
  /// <No documentation available>
  external ffi.Pointer<ffi.Uint8> ptr;

  /// <No documentation available>
  @ffi.Size()
  external int len;

  /// <No documentation available>
  @ffi.Size()
  external int cap;
}

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
typedef Vec_uint8_t = Vec_uint8;

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
final class Vec_double extends ffi.Struct {
  /// <No documentation available>
  external ffi.Pointer<ffi.Double> ptr;

  /// <No documentation available>
  @ffi.Size()
  external int len;

  /// <No documentation available>
  @ffi.Size()
  external int cap;
}

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
final class Vec_Vec_double extends ffi.Struct {
  /// <No documentation available>
  external ffi.Pointer<Vec_double_t> ptr;

  /// <No documentation available>
  @ffi.Size()
  external int len;

  /// <No documentation available>
  @ffi.Size()
  external int cap;
}

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
typedef Vec_double_t = Vec_double;

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
typedef Vec_Vec_double_t = Vec_Vec_double;

/// \brief
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/30
///
/// 像素图片
final class PixelsImage extends ffi.Struct {
  /// \brief
  /// 像素数据
  external Vec_uint8_t pixels;

  /// \brief
  /// 宽度
  @ffi.Uint32()
  external int w;

  /// \brief
  /// 高度
  @ffi.Uint32()
  external int h;
}

/// \brief
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/30
///
/// 像素图片
typedef PixelsImage_t = PixelsImage;

/// \brief
/// `Arc<dyn Send + Sync + Fn() -> Ret>`
final class ArcDynFn0_void extends ffi.Struct {
  /// <No documentation available>
  external ffi.Pointer<ffi.Void> env_ptr;

  /// <No documentation available>
  external ffi.Pointer<
      ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>
  >
  call;

  /// <No documentation available>
  external ffi.Pointer<
      ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>
  >
  release;

  /// <No documentation available>
  external ffi.Pointer<
      ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>
  >
  retain;
}

/// \brief
/// `Arc<dyn Send + Sync + Fn() -> Ret>`
typedef ArcDynFn0_void_t = ArcDynFn0_void;

/// \brief
/// `Box<dyn 'static + Send + FnMut() -> Ret>`
final class BoxDynFnMut0_void extends ffi.Struct {
  /// <No documentation available>
  external ffi.Pointer<ffi.Void> env_ptr;

  /// <No documentation available>
  external ffi.Pointer<
      ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>
  >
  call;

  /// <No documentation available>
  external ffi.Pointer<
      ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>
  >
  free;
}

/// \brief
/// `Box<dyn 'static + Send + FnMut() -> Ret>`
typedef BoxDynFnMut0_void_t = BoxDynFnMut0_void;

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
final class Vec_float extends ffi.Struct {
  /// <No documentation available>
  external ffi.Pointer<ffi.Float> ptr;

  /// <No documentation available>
  @ffi.Size()
  external int len;

  /// <No documentation available>
  @ffi.Size()
  external int cap;
}

/// \brief
/// Same as [`Vec<T>`][`rust::Vec`], but with guaranteed `#[repr(C)]` layout
typedef Vec_float_t = Vec_float;
