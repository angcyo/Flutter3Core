import 'package:flutter/cupertino.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/22
///

void main() {

  test('test svg path', () {
    WidgetsFlutterBinding.ensureInitialized();

    @mm
    final width = 160.0 /*.toDpFromMm()*/;
    final height = 160.0 /*.toDpFromMm()*/;

    @mm
    final bestWidth = 160.0;
    final bestHeight = 120.0;

    final validWidth = bestWidth * 0.6;
    final validHeight = bestHeight * 0.6;

    final l = (width - bestWidth) / 2;
    final t = (height - bestHeight) / 2;
    final r = l + bestWidth;
    final b = t + bestHeight;
    final cx = (l + r) / 2;
    final cy = (t + b) / 2;

    //debugger();
    final buffer = StringBuffer();

    final Path path = Path();
    path.moveTo(l, cy - validHeight / 2);
    path.quadraticBezierTo(l, t, cx - validWidth / 2, t);
    buffer.write('M $l ${cy - validHeight / 2} ');
    buffer.write('Q $l $t ${cx - validWidth / 2} $t ');

    path.lineTo(cx + validWidth / 2, t);
    path.quadraticBezierTo(r, t, r, cy - validHeight / 2);
    buffer.write('L ${cx + validWidth / 2} $t ');
    buffer.write('Q $r $t $r ${cy - validHeight / 2} ');

    path.lineTo(r, cy + validHeight / 2);
    path.quadraticBezierTo(r, b, cx + validWidth / 2, b);
    buffer.write('L $r ${cy + validHeight / 2} ');
    buffer.write('Q $r $b ${cx + validWidth / 2} $b ');

    path.lineTo(cx - validWidth / 2, b);
    path.quadraticBezierTo(l, b, l, cy + validHeight / 2);
    buffer.write('L ${cx - validWidth / 2} $b ');
    buffer.write('Q $l $b $l ${cy + validHeight / 2} ');

    path.lineTo(l, cy - validHeight / 2);
    buffer.write('L $l ${cy - validHeight / 2} ');

    final svgPath = path.toSvgPathString();
    consoleLog(svgPath);
    consoleLog(buffer);
  });
}
