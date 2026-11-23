library flutter3_vector;

import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_svg/svg.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

export 'package:flutter_svg/svg.dart';
export 'package:xml/xml.dart';

//@formatter:off
part 'src/gcode.dart';
part 'src/path_simulation.dart';
part 'src/svg_builder.dart';
part 'src/svg_pub.dart';
part 'src/vector_path_mix.dart';
part 'src/vector_write_handle.dart';
//@formatter:on

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/04
///
/// 矢量字符串扩展
extension VectorStringEx on String {
  /// 是否是GCode内容
  bool get isGCodeContent =>
      have("(G90)|(G91)\\s*(G20)|(G21)") || have("(G20)|(G21)\\s*(G90)|(G91)");

  /// 是否是svg内容
  bool get isSvgContent => have("</svg>");

  /// 是否是svg path路径数据
  bool get isSvgPathContent => startsWith("(m)|(M)".regex);
}
