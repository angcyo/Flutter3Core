library flutter3_vector;

import 'dart:async';
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

part 'src/gcode.dart';
part 'src/point.dart';
part 'src/svg_pub.dart';
part 'src/vector_write_handle.dart';

extension VectorStringEx on String {
  /// 是否是GCode内容
  bool get isGCodeContent =>
      have("(G90)|(G91)\\s*(G20)|(G21)") || have("(G20)|(G21)\\s*(G90)|(G91)");

  /// 是否是svg内容
  bool get isSvgContent => have("</svg>");
}
