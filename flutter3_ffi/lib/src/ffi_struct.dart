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
