part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/08/27
///
/// 微光固件动画小部件
class ShimmerSkeletonWidget extends StatefulWidget {
  static const double defaultSize = 1;
  static const double defaultAngle = pi / 12;
  static const Color defaultColor = Color(0x80FFFFFF);

  /// 骨架数据
  final SkeletonData? data;

  /// 动画时长
  final Duration duration;

  /// 动画开始的值
  final double? value;

  /// 是否自动播放
  final bool autoPlay;

  /// 微光颜色
  @defInjectMark
  final List<Color>? colors;

  const ShimmerSkeletonWidget({
    super.key,
    required this.data,
    this.duration = const Duration(milliseconds: 3000),
    this.value,
    this.autoPlay = true,
    this.colors,
  });

  @override
  State<ShimmerSkeletonWidget> createState() => _ShimmerSkeletonWidgetState();
}

class _ShimmerSkeletonWidgetState extends State<ShimmerSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShimmerSkeletonWidget oldWidget) {
    //debugger();
    if (oldWidget.duration != widget.duration) {
      _initController();
      _play();
    } else if (widget.value != oldWidget.value) {
      _play();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final body = SkeletonWidget(data: widget.data);
    //l.v("animationValue:${_controller.value}");
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, _) {
        return body.shaderMask(
          null,
          shaderCallback: (Rect rect) {
            //l.v("animationValue:${_controller.value}");
            //debugger();
            //linearGradientShader();
            return LinearGradient(
              colors:
                  widget.colors ??
                  [
                    Colors.transparent,
                    ShimmerSkeletonWidget.defaultColor,
                    Colors.transparent,
                  ],
              /*stops: const [0.0, 0.5, 1.0],*/
              /*begin: Alignment.topLeft,
              end: Alignment.bottomRight,*/
              transform: _SweepingGradientTransform(
                ratio: _controller.value,
                angle: ShimmerSkeletonWidget.defaultAngle,
                scale: ShimmerSkeletonWidget.defaultSize,
              ),
            ).createShader(Rect.fromLTWH(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.srcATop,
        );
      },
    );
  }

  void _play() {
    //debugger();
    _updateValue();
    if (widget.autoPlay) {
      //_controller.forward(from: widget.value ?? 0);
      _controller.repeat();
      //widget.onPlay?.call(_controller);
    }
  }

  void _restart() {
    _initController();
    _updateValue();
    _play();
  }

  void _updateValue() {
    if (widget.value == null) return;
    _controller.value = widget.value!;
  }

  void _initController() {
    AnimationController? controller;
    bool callback = false;

    controller = AnimationController(vsync: this);

    if (controller != null) {
      // new controller.
      _controller = controller;
      _controller.addStatusListener(_handleAnimationStatus);
    }

    _controller.duration = widget.duration;

    //if (callback) widget.onInit?.call(_controller);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      //widget.onComplete?.call(_controller);
    }
  }

  void _disposeController() {
    _controller.dispose();
  }
}

class _SweepingGradientTransform extends GradientTransform {
  const _SweepingGradientTransform({
    required this.ratio,
    required this.angle,
    required this.scale,
  });

  final double angle;
  final double ratio;
  final double scale;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // minimum width / height to avoid infinity errors:
    double w = max(0.01, bounds.width), h = max(0.01, bounds.height);

    // calculate the radius of the rect:
    double r = (cos(angle) * w).abs() + (sin(angle) * h).abs();

    // set up the transformation matrices:
    Matrix4 transformMtx = Matrix4.identity()
      ..rotateZ(angle)
      ..scale(r / w * scale);

    double range = w * (1 + scale) / scale;
    Matrix4 translateMtx = Matrix4.identity()..translate(range * (ratio - 0.5));

    // Convert from [-1 - +1] to [0 - 1], & find the pixel location of the gradient center:
    Offset pt = Offset(bounds.left + w * 0.5, bounds.top + h * 0.5);

    // This offsets the draw position to account for the widget's position being
    // multiplied against the transformation:
    List<double> loc = transformMtx.applyToVector3Array([pt.dx, pt.dy, 0.0]);
    double dx = pt.dx - loc[0], dy = pt.dy - loc[1];

    return Matrix4.identity()
      ..translate(dx, dy, 0.0) // center origin
      ..multiply(transformMtx) // rotate and scale
      ..multiply(translateMtx); // translate
  }
}

/// 骨架小部件
class SkeletonWidget extends LeafRenderObjectWidget {
  final SkeletonData? data;

  const SkeletonWidget({super.key, required this.data});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SkeletonRender(data: data);
  }

  @override
  void updateRenderObject(BuildContext context, SkeletonRender renderObject) {
    renderObject
      ..data = data
      ..markNeedsPaint();
  }
}

/// 渲染器
class SkeletonRender extends RenderBox {
  SkeletonData? data;

  SkeletonRender({this.data});

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    //debugger();
    size = constraints.biggest;
    /*assert(() {
      l.d("骨架大小: $size");
      return true;
    }());*/
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //debugger();
    final canvas = context.canvas;
    //canvas.drawColor(Colors.green, BlendMode.src);
    if (data != null) {
      _paintSkeleton(canvas, offset, size, data!);
    }
    debugPaintBoxBounds(context, offset);
  }

  /// 绘制骨架
  /// - [offset] 整体的偏移
  /// - [childOffset] 子元素的偏移
  /// @return 返回绘制的区域, 包含了边距
  Rect _paintSkeleton(
    Canvas canvas,
    Offset offset,
    Size contentSize,
    SkeletonData data,
  ) {
    final w = v(data.width, contentSize);
    final h = v(data.height, contentSize);

    final fw = v(data.fillWidth, contentSize);
    final fh = v(data.fillHeight, contentSize);

    final marginLeft = v(data.left, contentSize);
    final marginTop = v(data.top, contentSize);
    final marginRight = v(data.right, contentSize);
    final marginBottom = v(data.bottom, contentSize);

    // 自身的整体区域, 包含边距, 包含child
    Rect selfRect = Rect.fromLTWH(offset.dx, offset.dy, w, h);
    Rect drawRect = Rect.fromLTWH(
      selfRect.left + marginLeft,
      selfRect.top + marginTop,
      w,
      h,
    );
    selfRect = selfRect.expandToInclude(drawRect);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = data.color;

    if (data.type == SkeletonDataType.rect) {
      final rx = v(data.rx, contentSize);
      final ry = v(data.ry, contentSize);

      final radius = Radius.elliptical(rx, ry);

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          drawRect,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint,
      );

      /*assert(() {
        l.d("绘制矩形: $drawRect");
        return true;
      }());*/
    } else if (data.type == SkeletonDataType.circle) {
      canvas.drawOval(drawRect, paint);
      /*assert(() {
        l.d("绘制圆: $drawRect");
        return true;
      }());*/
    } else {
      //no op
    }

    //debugger();
    final childContentSize =
        contentSize +
        Offset(-marginLeft - marginRight, -marginTop - marginBottom);
    final childOffset = Offset(marginLeft, marginTop);
    data.children?.forEach((child) {
      //debugger(when: child.type == SkeletonDataType.rect);
      final rect = _paintSkeleton(
        canvas,
        offset + childOffset,
        childContentSize,
        child,
      );
      //debugger();
      selfRect = selfRect.expandToInclude(rect);
      /*assert(() {
        l.v("selfRect: $selfRect");
        return true;
      }());*/
      //debugger();
    });

    //填充宽度
    final selfWidth = selfRect.width;
    double filledWidth = selfWidth;
    while (fw > filledWidth && selfRect.right < size.width) {
      //debugger();
      final childLeftOffset = filledWidth + marginRight;
      data.children?.forEach((child) {
        final rect = _paintSkeleton(
          canvas,
          offset + Offset(childLeftOffset, 0),
          childContentSize,
          child,
        );
        selfRect = selfRect.expandToInclude(rect);
      });
      filledWidth += selfWidth + marginRight;
    }
    //填充高度
    //debugger(when: fh > 0);
    final selfHeight = selfRect.height;
    double filledHeight = selfHeight;
    while (fh > filledHeight && selfRect.bottom < size.height) {
      //debugger();
      final childTopOffset = filledHeight + marginBottom;
      data.children?.forEach((child) {
        final rect = _paintSkeleton(
          canvas,
          offset + Offset(0, childTopOffset),
          childContentSize,
          child,
        );
        selfRect = selfRect.expandToInclude(rect);
      });
      filledHeight += selfHeight + marginBottom;
    }
    //debugger();

    selfRect = Rect.fromLTRB(
      selfRect.left,
      selfRect.top,
      selfRect.right + marginRight,
      selfRect.bottom + marginBottom,
    );

    /*assert(() {
      if (data.children != null) {
        canvas.drawRect(
          selfRect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.black45,
        );
        */ /*assert(() {
          l.d("绘制selfRect: $selfRect");
          return true;
        }());*/ /*
      }
      return true;
    }());*/

    return selfRect;
  }

  /// ## 数值:,
  /// - 如果是<=1, 则表示在容器中的比例
  /// - 如果是 >1, 则表示dp值
  ///
  /// ## 数值单位:
  /// - w : 比例参考值容器宽度(默认)
  /// - h : 比例参考值容器宽度
  /// - cw : 比例参考值内容宽度
  /// - ch : 比例参考值内容宽度
  ///
  /// ```
  /// 0.1w+20+20+0.1h
  /// ```
  double v(String value, Size contentSize) {
    //解析出来的表达式, 包含数字和符号
    final expList = <Object>[];

    final numBuffer = StringBuffer();
    final refBuffer = StringBuffer();

    void handleNum() {
      if (numBuffer.isNotEmpty) {
        expList.add(_value("$numBuffer$refBuffer", contentSize));
      }
      numBuffer.clear();
      refBuffer.clear();
    }

    value.forEach((s) {
      if (s == "." ||
          s == "0" ||
          s == "1" ||
          s == "2" ||
          s == "3" ||
          s == "4" ||
          s == "5" ||
          s == "6" ||
          s == "7" ||
          s == "8" ||
          s == "9") {
        //数字 小数
        numBuffer.write(s);
      } else if (s == "c") {
        //参考值
        if (refBuffer.isEmpty) {
          refBuffer.write(s);
        }
      } else if (s == "w" || s == "h") {
        //参考值
        if (refBuffer.isEmpty) {
          refBuffer.write(s);
        }
      } else if (s == "+" || s == "-") {
        if (numBuffer.isNotEmpty) {
          handleNum();
          expList.add(s);
        }
      } else {
        handleNum();
      }
    });
    handleNum();

    //debugger(when: !isNil(value));
    double result = 0;
    int index = 0;
    while (index < expList.length) {
      final exp = expList[index];
      if (exp is String) {
        index++;
        final exp2 = expList[index];
        if (exp2 is double) {
          if (exp == "+") {
            index++;
            result += exp2;
          } else if (exp == "-") {
            index++;
            result -= exp2;
          }
        }
      } else if (exp is double) {
        index++;
        result += exp;
      } else {
        index++;
      }
    }

    //debugger(when: !isNil(value));
    return result;
  }

  double _value(String value, Size contentSize) {
    double v = 0;
    //参考值
    double ref = size.width;
    if (value.endsWith("cw")) {
      ref = contentSize.width;
      v = value.substring(0, value.length - 2).toDoubleOrNull() ?? 0;
    } else if (value.endsWith("ch")) {
      ref = contentSize.height;
      v = value.substring(0, value.length - 2).toDoubleOrNull() ?? 0;
    } else if (value.endsWith("h")) {
      ref = size.height;
      v = value.substring(0, value.length - 1).toDoubleOrNull() ?? 0;
    } else if (value.endsWith("w")) {
      v = value.substring(0, value.length - 1).toDoubleOrNull() ?? 0;
    } else {
      v = value.toDoubleOrNull() ?? 0;
    }
    return v <= 1 ? v * ref : v;
  }
}

/// # 骨架数据
///
/// ## 数值:,
/// - 如果是<=1, 则表示在容器中的比例
/// - 如果是 >1, 则表示dp值
///
/// ## 数值单位:
/// - w : 比例参考值容器宽度(默认)
/// - h : 比例参考值容器宽度
/// - cw : 比例参考值内容宽度
/// - ch : 比例参考值内容宽度
///
class SkeletonData {
  /// 绘制的类型
  final SkeletonDataType type;

  /// 颜色
  final Color color;

  /// 宽高
  final String width;
  final String height;

  /// [children] 需要铺满的宽度和高度
  /// 会循环绘制, 直到[children]宽高超过指定的值
  final String fillWidth;
  final String fillHeight;

  /// 矩形的圆角
  final String rx;
  final String ry;

  /// 绘制时的左上右下的边距
  final String left;
  final String top;
  final String right;
  final String bottom;

  /// 子元素
  final List<SkeletonData>? children;

  SkeletonData({
    this.type = SkeletonDataType.none,
    this.width = "",
    this.height = "",
    this.color = Colors.white,
    //--
    this.fillWidth = "",
    this.fillHeight = "",
    //--
    this.rx = "",
    this.ry = "",
    //--
    this.left = "",
    this.top = "",
    this.right = "",
    this.bottom = "",
    //--
    this.children,
  });
}

enum SkeletonDataType {
  /// 不绘制, 只定位
  none,

  /// 矩形
  rect,

  /// 圆形
  circle,
}
