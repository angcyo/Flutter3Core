part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/04
///
/// 箭头小部件/三角形, 支持全三角和半三角
/// [TrianglePainter]
/// [ArrowWidget]
///
/// [ArrowPosition]
/// [ArrowPositionManager]
///
/// [ElTooltip]
///
/// https://pub.dev/packages/el_tooltip
class ArrowWidget extends StatelessWidget {
  final Color color;
  final ArrowPosition arrowPosition;
  final double width;
  final double height;
  final List<BoxShadow>? boxShadow;

  const ArrowWidget({
    this.color = Colors.redAccent,
    this.arrowPosition = ArrowPosition.rightCenter,
    this.width = 16.0,
    this.height = 10.0,
    this.boxShadow,
    super.key,
  });

  /// Returns either the center triangle or the corner triangle
  CustomPainter? _getElement(bool isArrow) {
    return isArrow
        ? ArrowTrianglePainter(color: color, boxShadow: boxShadow)
        : ArrowCornerPainter(color: color, boxShadow: boxShadow);
  }

  /// Applies the transformation to the triangle
  Widget _getTriangle() {
    double scaleX = 1;
    double scaleY = 1;
    bool isArrow = false;
    int quarterTurns = 0;

    switch (arrowPosition) {
      case ArrowPosition.topStart:
        break;
      case ArrowPosition.topCenter:
        quarterTurns = 0;
        isArrow = true;
        break;
      case ArrowPosition.topEnd:
        scaleX = -1;
        break;
      case ArrowPosition.bottomStart:
        scaleY = -1;
        break;
      case ArrowPosition.bottomCenter:
        quarterTurns = 2;
        isArrow = true;
        break;
      case ArrowPosition.bottomEnd:
        scaleX = -1;
        scaleY = -1;
        break;
      case ArrowPosition.leftStart:
        scaleY = -1;
        quarterTurns = 3;
        break;
      case ArrowPosition.leftCenter:
        quarterTurns = 3;
        isArrow = true;
        break;
      case ArrowPosition.leftEnd:
        quarterTurns = 3;
        break;
      case ArrowPosition.rightStart:
        quarterTurns = 1;
        break;
      case ArrowPosition.rightCenter:
        quarterTurns = 1;
        isArrow = true;
        break;
      case ArrowPosition.rightEnd:
        quarterTurns = 1;
        scaleY = -1;
        break;
    }

    return Transform.scale(
      scaleX: scaleX,
      scaleY: scaleY,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: CustomPaint(
          size: Size(width, height),
          painter: _getElement(isArrow),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getTriangle();
  }
}

/// 箭头的位置
/// [ElTooltipPosition]
enum ArrowPosition {
  topStart,
  topCenter,
  topEnd,
  rightStart,
  rightCenter,
  rightEnd,
  bottomStart,
  bottomCenter,
  bottomEnd,
  leftStart,
  leftCenter,
  leftEnd,
}

extension ArrowPositionEx on ArrowPosition {
  Alignment get alignment => switch (this) {
        ArrowPosition.topStart => Alignment.bottomLeft,
        ArrowPosition.topCenter => Alignment.topCenter,
        ArrowPosition.topEnd => Alignment.bottomRight,
        //--
        ArrowPosition.rightStart => Alignment.topLeft,
        ArrowPosition.rightCenter => Alignment.centerLeft,
        ArrowPosition.rightEnd => Alignment.bottomLeft,
        //--
        ArrowPosition.bottomStart => Alignment.topLeft,
        ArrowPosition.bottomCenter => Alignment.topCenter,
        ArrowPosition.bottomEnd => Alignment.topRight,
        //--
        ArrowPosition.leftStart => Alignment.topRight,
        ArrowPosition.leftCenter => Alignment.centerRight,
        ArrowPosition.leftEnd => Alignment.bottomRight,
      };
}

/// Design of the triangle that appears attached to the tooltip
class ArrowTrianglePainter extends CustomPainter {
  final List<BoxShadow>? boxShadow;

  /// [color] of the arrow.
  final Color color;

  ArrowTrianglePainter({
    this.color = const Color(0xff000000),
    this.boxShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.isAntiAlias = false;
    paint.color = color;
    Path path = Path();

    path.lineTo(size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.58, size.height * 1.05, size.width * 0.42,
        size.height * 1.05, size.width * 0.34, size.height * 0.86);
    path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width * 0.66, size.height * 0.86,
        size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.66, size.height * 0.86, size.width * 0.66,
        size.height * 0.86, size.width * 0.66, size.height * 0.86);

    canvas.drawShadows(Offset.zero & size, boxShadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Design of the corner triangle that appears attached to the tooltip
class ArrowCornerPainter extends CustomPainter {
  final List<BoxShadow>? boxShadow;

  /// [color] of the arrow.
  final Color color;

  ArrowCornerPainter({
    this.color = const Color(0xff000000),
    this.boxShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();
    paint.color = color;
    path = Path();
    path.lineTo(0, size.height * 0.69);
    path.cubicTo(0, size.height * 0.95, size.width * 0.18, size.height * 1.09,
        size.width * 0.31, size.height * 0.93);
    path.cubicTo(
        size.width * 0.31, size.height * 0.93, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, 0, 0, 0, 0);
    path.cubicTo(0, 0, 0, size.height * 0.69, 0, size.height * 0.69);
    path.cubicTo(
        0, size.height * 0.69, 0, size.height * 0.69, 0, size.height * 0.69);

    canvas.drawShadows(Offset.zero & size, boxShadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 箭头位置管理
/// 输出的位置信息都是参考[screenSize]的位置
///
/// [ArrowPosition]
/// [ArrowPositionManager]
///
class ArrowPositionManager {
  /// 箭头的大小
  Size arrowSize = Size.zero;

  /// 锚点所在的全局矩形
  Rect anchorBox = Rect.zero;

  /// 内容的大小
  Size contentSize = Size.zero;

  /// 屏幕的大小
  Size screenSize = Size(screenWidth, screenHeight);

  /// 偏移锚点的距离
  double arrowOffset = 0;

  /// 箭头距离内容之间的距离
  double offset = 0;

  /// 圆角, 输出时背景的圆角信息
  Radius radius = Radius.zero;

  //--

  /// 是否加载过
  @output
  @flagProperty
  bool isLoad = false;

  /// 输出的箭头的位置
  @output
  Rect outputArrowRect = Rect.zero;

  /// 输出箭头额外的偏移量
  @output
  Rect outputArrowOffsetRect = Rect.zero;

  /// 输出的内容的位置, 不包含箭头的大小, 但是包含箭头的位置
  @output
  Rect outputContentRect = Rect.zero;

  /// 输出的圆角信息
  @output
  BorderRadiusGeometry outputRadius = BorderRadius.zero;

  /// 输出的箭头的位置
  @output
  ArrowPosition outputArrowPosition = ArrowPosition.rightCenter;

  //--

  /// 整体包含箭头的输出边界
  Rect get outputBounds => outputArrowRect.expandToInclude(outputContentRect);

  /// 单独箭头的输出边界
  Rect get outputArrowBounds => applyArrowOffset(outputArrowRect);

  /// 将一个矩形, 应用[outputArrowOffsetRect]
  Rect applyArrowOffset(Rect rect) => Rect.fromLTRB(
        rect.left - outputArrowOffsetRect.left,
        rect.top - outputArrowOffsetRect.top,
        rect.right + outputArrowOffsetRect.right,
        rect.bottom + outputArrowOffsetRect.bottom,
      );

  //--temp

  @implementation
  Offset tempPosition = Offset.zero;

  ArrowPositionManager();

  _topStart() {
    outputArrowOffsetRect = rectLTRB(b: arrowOffset);
    outputArrowRect = Rect.fromLTWH(
      (anchorBox.left + _half(anchorBox.width)).floorToDouble(),
      (anchorBox.top - offset - arrowSize.height).floorToDouble() -
          1 -
          arrowOffset,
      arrowSize.width,
      arrowSize.height,
    );
    outputContentRect = Rect.fromLTWH(
      outputArrowRect.left,
      outputArrowRect.top - contentSize.height - offset,
      contentSize.width,
      contentSize.height,
    );
    outputArrowPosition = ArrowPosition.topStart;
    outputRadius = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: Radius.zero,
      bottomRight: radius,
    );
  }

  _topCenter() {
    outputArrowOffsetRect = rectLTRB(b: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: (anchorBox.left + _half(anchorBox.width) - _half(arrowSize.width))
          .floorToDouble(),
      y: (anchorBox.top - arrowSize.height).floorToDouble() - 1 - arrowOffset,
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: anchorBox.left + _half(anchorBox.width) - _half(contentSize.width),
      y: outputArrowRect.top - contentSize.height - offset,
    );
    outputArrowPosition = ArrowPosition.topCenter;
    outputRadius = BorderRadius.all(radius);
  }

  _topEnd() {
    outputArrowOffsetRect = rectLTRB(b: arrowOffset);
    outputArrowPosition = ArrowPosition.topEnd;
    outputRadius = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: Radius.zero,
    );
    outputArrowRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: (anchorBox.left + _half(anchorBox.width) - arrowSize.width)
          .floorToDouble(),
      y: (anchorBox.top - arrowSize.height).floorToDouble() - 1 - arrowOffset,
    );
    outputContentRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: anchorBox.left - contentSize.width + _half(anchorBox.width),
      y: outputArrowRect.top - contentSize.height - offset,
    );
  }

  _bottomStart() {
    outputArrowOffsetRect = rectLTRB(t: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: (anchorBox.left + _half(anchorBox.width)).ceilToDouble(),
      y: (anchorBox.top + anchorBox.h).ceilToDouble() + arrowOffset,
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: anchorBox.left + _half(anchorBox.width),
      y: outputArrowRect.top + offset + arrowSize.height,
    );
    outputArrowPosition = ArrowPosition.bottomStart;
    outputRadius = BorderRadius.only(
      topLeft: Radius.zero,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
    );
  }

  _bottomCenter() {
    outputArrowOffsetRect = rectLTRB(t: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: (anchorBox.left + _half(anchorBox.width) - _half(arrowSize.width))
          .ceilToDouble(),
      y: (anchorBox.top + anchorBox.h).ceilToDouble() + arrowOffset,
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: anchorBox.left + _half(anchorBox.width) - _half(contentSize.width),
      y: outputArrowRect.top + offset + arrowSize.height,
    );
    outputArrowPosition = ArrowPosition.bottomCenter;
    outputRadius = BorderRadius.all(radius);
  }

  _bottomEnd() {
    outputArrowOffsetRect = rectLTRB(t: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: (anchorBox.left + _half(anchorBox.width) - arrowSize.width),
      y: (anchorBox.top + anchorBox.h).ceilToDouble() + arrowOffset,
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: anchorBox.left + _half(anchorBox.width) - contentSize.width,
      y: outputArrowRect.top + offset + arrowSize.height,
    );
    outputArrowPosition = ArrowPosition.bottomEnd;
    outputRadius = BorderRadius.only(
      topLeft: radius,
      topRight: Radius.zero,
      bottomLeft: radius,
      bottomRight: radius,
    );
  }

  _leftStart() {
    outputArrowOffsetRect = rectLTRB(r: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.height,
      h: arrowSize.width,
      x: (anchorBox.left - arrowSize.height).floorToDouble() - arrowOffset,
      y: anchorBox.top + _half(anchorBox.h),
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: outputArrowRect.left - contentSize.width - offset,
      y: anchorBox.top + _half(anchorBox.h),
    );
    outputArrowPosition = ArrowPosition.leftStart;
    outputRadius = BorderRadius.only(
      topLeft: radius,
      topRight: Radius.zero,
      bottomLeft: radius,
      bottomRight: radius,
    );
  }

  _leftCenter() {
    outputArrowOffsetRect = rectLTRB(r: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.height,
      h: arrowSize.width,
      x: (anchorBox.left - arrowSize.height).floorToDouble() - arrowOffset,
      y: (anchorBox.top + _half(anchorBox.h) - _half(arrowSize.width))
          .floorToDouble(),
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: outputArrowRect.left - contentSize.width - offset,
      y: anchorBox.top + _half(anchorBox.h) - _half(contentSize.height),
    );
    outputArrowPosition = ArrowPosition.leftCenter;
    outputRadius = BorderRadius.all(radius);
  }

  _leftEnd() {
    outputArrowOffsetRect = rectLTRB(r: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.height,
      h: arrowSize.width,
      x: (anchorBox.left - offset - arrowSize.height).floorToDouble() -
          arrowOffset,
      y: (anchorBox.top + _half(anchorBox.h) - arrowSize.width).floorToDouble(),
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: outputArrowRect.left - contentSize.width - offset,
      y: anchorBox.top + _half(anchorBox.h) - contentSize.height,
    );
    outputArrowPosition = ArrowPosition.leftEnd;
    outputRadius = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: Radius.zero,
    );
  }

  _rightStart() {
    outputArrowOffsetRect = rectLTRB(l: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.width,
      h: arrowSize.height,
      x: (anchorBox.left + anchorBox.width).floorToDouble() + arrowOffset,
      y: (anchorBox.top + _half(anchorBox.h)).floorToDouble(),
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: outputArrowRect.left + arrowSize.height + offset,
      y: (anchorBox.top + _half(anchorBox.h)).floorToDouble(),
    );
    outputArrowPosition = ArrowPosition.rightStart;
    outputRadius = BorderRadius.only(
      topLeft: Radius.zero,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
    );
  }

  _rightCenter() {
    outputArrowOffsetRect = rectLTRB(l: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.height,
      h: arrowSize.width,
      x: (anchorBox.left + anchorBox.width).floorToDouble() + 1 + arrowOffset,
      y: (anchorBox.top + _half(anchorBox.h) - _half(arrowSize.width))
          .floorToDouble(),
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: outputArrowRect.left + offset + arrowSize.height,
      y: anchorBox.top + _half(anchorBox.h) - _half(contentSize.height),
    );
    outputArrowPosition = ArrowPosition.rightCenter;
    outputRadius = BorderRadius.all(radius);
  }

  _rightEnd() {
    outputArrowOffsetRect = rectLTRB(l: arrowOffset);
    outputArrowRect = rect(
      w: arrowSize.height,
      h: arrowSize.width,
      x: (anchorBox.left + anchorBox.width).floorToDouble() + 1 + arrowOffset,
      y: anchorBox.top + _half(anchorBox.h) - arrowSize.width,
    );
    outputContentRect = rect(
      w: contentSize.width,
      h: contentSize.height,
      x: outputArrowRect.left + offset + arrowSize.height,
      y: anchorBox.top + _half(anchorBox.h) - contentSize.height,
    );
    outputArrowPosition = ArrowPosition.rightEnd;
    outputRadius = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: Radius.zero,
      bottomRight: radius,
    );
  }

  double _half(double size) {
    return size * 0.5;
  }

  bool _fitsScreen() {
    if (outputContentRect.x > 0 &&
        outputContentRect.x + outputContentRect.w < screenSize.width &&
        outputContentRect.y > 0 &&
        outputContentRect.y + outputContentRect.h < screenSize.height) {
      return true;
    }
    return false;
  }

  /// Tests each possible position until it finds one that fits.
  _firstAvailablePosition() {
    List<Function()> positions = [
      _topCenter,
      _bottomCenter,
      _leftCenter,
      _rightCenter,
      _topStart,
      _topEnd,
      _leftStart,
      _rightStart,
      _leftEnd,
      _rightEnd,
      _bottomStart,
      _bottomEnd,
    ];
    for (var position in positions) {
      if (_fitsScreen()) return position();
    }
    //return _topCenter();
  }

  /// Load the calculated tooltip position
  void load({
    bool isLoad = true,
    Size? arrowSize,
    Rect? anchorBox,
    Size? contentSize,
    Size? screenSize,
    double? offset,
    Radius? radius,
    ArrowPosition? preferredPosition,
  }) {
    this.isLoad = isLoad;
    //debugger();
    this.arrowSize = arrowSize ?? this.arrowSize;
    this.anchorBox = anchorBox ?? this.anchorBox;
    this.contentSize = contentSize ?? this.contentSize;
    this.screenSize = screenSize ?? this.screenSize;
    this.offset = offset ?? this.offset;
    this.radius = radius ?? this.radius;

    if (preferredPosition == null) {
      //没有指定位置, 则自动计算位置
      if (this.anchorBox.centerX < this.screenSize.width / 2) {
        //锚点在屏幕的左侧, 则向右显示箭头
        if (this.anchorBox.centerY > this.contentSize.height / 2) {
          //顶部有足够多的位置容纳内容
          if (this.anchorBox.centerX > this.contentSize.width / 2) {
            //虽然在左侧, 但是左侧还有足够多的空间显示内容
            preferredPosition = ArrowPosition.topCenter;
          } else {
            preferredPosition = ArrowPosition.rightCenter;
          }
        } else {
          if (this.anchorBox.centerX > this.contentSize.width / 2) {
            //虽然在左侧, 但是左侧还有足够多的空间显示内容
            preferredPosition = ArrowPosition.bottomCenter;
          } else {
            preferredPosition = ArrowPosition.rightStart;
          }
        }
      } else {
        //锚点在屏幕的右侧, 则向左显示箭头
        if (this.anchorBox.centerY > this.contentSize.height / 2) {
          //顶部有足够多的位置容纳内容, 锚点在, 右侧下半部
          if ((this.screenSize.width - this.anchorBox.centerX) >
              this.contentSize.width / 2) {
            //虽然在右侧, 但是右侧还有足够多的空间显示内容
            if (this.anchorBox.bottom > this.contentSize.height) {
              //底部够空间
              preferredPosition = ArrowPosition.bottomCenter;
            } else {
              preferredPosition = ArrowPosition.topCenter;
              //否则显示在顶部
            }
            //debugger();
          } else {
            preferredPosition = ArrowPosition.leftCenter;
          }
        } else {
          //锚点在, 右侧上半部
          if ((this.screenSize.width - this.anchorBox.centerX) >
              this.contentSize.width / 2) {
            //虽然在右侧, 但是右侧还有足够多的空间显示内容
            if (this.anchorBox.bottom > this.contentSize.height) {
              //底部够空间
              preferredPosition = ArrowPosition.bottomCenter;
            } else {
              //否则显示在顶部部
              preferredPosition = ArrowPosition.topCenter;
            }
          } else {
            preferredPosition = ArrowPosition.leftStart;
          }
        }
      }
      /*assert(() {
        l.d("自动匹配的位置->$preferredPosition");
        return true;
      }());*/
    }

    //debugger();
    switch (preferredPosition) {
      case ArrowPosition.topStart:
        _topStart();
        break;
      case ArrowPosition.topCenter:
        _topCenter();
        break;
      case ArrowPosition.topEnd:
        _topEnd();
        break;
      case ArrowPosition.bottomStart:
        _bottomStart();
        break;
      case ArrowPosition.bottomCenter:
        _bottomCenter();
        break;
      case ArrowPosition.bottomEnd:
        _bottomEnd();
        break;
      case ArrowPosition.leftStart:
        _leftStart();
        break;
      case ArrowPosition.leftCenter:
        _leftCenter();
        break;
      case ArrowPosition.leftEnd:
        _leftEnd();
        break;
      case ArrowPosition.rightStart:
        _rightStart();
        break;
      case ArrowPosition.rightCenter:
        _rightCenter();
        break;
      case ArrowPosition.rightEnd:
        _rightEnd();
        break;
    }

    //debugger();
    if (!_fitsScreen()) {
      _firstAvailablePosition();
    }
  }
}
