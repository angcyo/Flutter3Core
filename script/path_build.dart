import '_script_common.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/21
///
void main() {
  final left = 20.0;
  final top = 20.0;
  final width = 140.0;
  final height = 140.0;

  //--1
  final right = left + width;
  final bottom = top + height;

  var builder = StringBuffer();
  builder
    ..write("M$left $top")
    ..write("L$right $top")
    ..write("L$right $bottom")
    ..write("L$left $bottom")
    ..write("Z");
  colorLog(builder);

  //--2
  builder = StringBuffer();
  final validWidth = width * 0.8;
  final validHeight = height * 0.8;

  final leftIndent = left + (width - validWidth) / 2;
  final topIndent = top + (height - validHeight) / 2;
  final rightIndent = leftIndent + validWidth;
  final bottomIndent = topIndent + validHeight;
  builder
    ..write("M$leftIndent $top")
    ..write("L${leftIndent + validWidth} $top")
    ..write("Q$right $top $right $topIndent")
    ..write("L$right ${topIndent + validHeight}")
    ..write("Q$right $bottom $rightIndent $bottom")
    ..write("L$leftIndent $bottom")
    ..write("Q$left $bottom $left $bottomIndent")
    ..write("L$left $topIndent")
    ..write("Q$left $top $leftIndent $top")
    ..write("Z");
  colorLog(builder);
}
