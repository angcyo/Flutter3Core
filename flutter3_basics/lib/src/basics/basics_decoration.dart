part of '../../flutter3_basics.dart';

/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

//region BoxDecoration

/// 空的[Decoration], 空装饰, 占位装饰
final Decoration kEmptyDecoration = PaintDecoration(null);

/// 自定义绘制装饰器
/// [BoxDecoration] 装饰
/// [PaintFn]
class PaintDecoration extends Decoration {
  final PaintFn? paint;

  const PaintDecoration(this.paint);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return PaintBoxPainter(paint, onChanged);
  }
}

/// 带进度的[BoxDecoration]装饰
class ProgressBoxDecoration extends BoxDecoration {
  /// 进度[0~1]
  /// - [ProgressStateInfo]
  final double? progress;

  /// 调试标签
  final String? debugLabel;

  const ProgressBoxDecoration({
    this.progress,
    this.debugLabel,
    super.color,
    super.image,
    super.border,
    super.borderRadius,
    super.boxShadow,
    super.gradient,
    super.backgroundBlendMode,
    super.shape = BoxShape.rectangle,
  });

  /// 此方法会在[RenderDecoratedBox.paint]方法中创建一次并缓存
  @override
  BoxPainter createBoxPainter([ui.VoidCallback? onChanged]) {
    debugger(when: !isIos && debugLabel != null);
    final parent = super.createBoxPainter(onChanged);
    return ProgressBoxPainter(parent, onChanged, progress: progress);
  }
}

class ProgressBoxPainter extends BoxPainter {
  /// 进度[0~1]
  /// - [ProgressStateInfo]
  final double? progress;

  final BoxPainter parentPainter;

  const ProgressBoxPainter(
    this.parentPainter,
    super.onChanged, {
    this.progress,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final progress = this.progress;
    //debugger(when: progress != null);
    if (progress == null || progress == ProgressStateInfo.noProgress) {
      parentPainter.paint(canvas, offset, configuration);
    } else if (progress == ProgressStateInfo.infinityProgress) {
    } else if (progress >= 0 && progress <= 1) {
      final Rect rect = offset & configuration.size!;
      canvas.withClipRect(
        Rect.fromLTWH(
          rect.left,
          rect.top,
          progress == 0 ? 1 : rect.width * progress,
          rect.height,
        ),
        () {
          parentPainter.paint(canvas, offset, configuration);
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    parentPainter.dispose();
  }
}

class PaintBoxPainter extends BoxPainter {
  final PaintFn? paintFn;

  PaintBoxPainter(this.paintFn, super.onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    //super.paint(canvas, offset, configuration);
    //debugger();
    if (paintFn != null) {
      canvas.withTranslate(offset.dx, offset.dy, () {
        paintFn?.call(canvas, configuration.size ?? Size.zero);
      });
    }
  }
}

/// 虚线装饰器
class DashedBorderDecoration extends Decoration {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  const DashedBorderDecoration({
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.borderRadius = 0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return DashedBorderPainter(this, onChanged);
  }
}

class DashedBorderPainter extends BoxPainter {
  final DashedBorderDecoration config;

  DashedBorderPainter(this.config, super.onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final rect = offset & configuration.size!;

    final paint = Paint()
      ..color = config.color
      ..strokeWidth = config.strokeWidth
      ..style = PaintingStyle.stroke;

    // 使用 Path 创建一个矩形（或圆角矩形）
    final Path targetPath = Path();
    if (config.borderRadius > 0) {
      targetPath.addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(config.borderRadius)),
      );
    } else {
      targetPath.addRect(rect);
    }

    // 将连续的 Path 转化为虚线 Path
    final Path dashedPath = Path();

    // 核心算法：遍历整个路径，分段截取
    for (PathMetric pathMetric in targetPath.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        double len = draw ? config.dashWidth : config.dashSpace;
        // 防止最后一段溢出
        if (distance + len > pathMetric.length) {
          len = pathMetric.length - distance;
        }

        if (draw) {
          dashedPath.addPath(
            pathMetric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw; // 切换“绘制”与“空白”状态
      }
    }

    // 真正绘制到画布上
    canvas.drawPath(dashedPath, paint);
  }
}

//MARK: - METHOD

/// 虚线装饰
/// [color] 描边颜色
/// [strokeWidth] 描边宽度
/// [fillDecoration]
DashedBorderDecoration dashedDecoration({
  Color? color,
  BuildContext? context,
  double? strokeWidth,
  double? dashWidth,
  double? dashSpace,
  double? radius = kDefaultBorderRadiusXX,
}) {
  //globalTheme.borderColor
  final strokeColor = color ?? GlobalTheme.of(context).accentColor;
  return DashedBorderDecoration(
    color: strokeColor,
    strokeWidth: strokeWidth ?? 1,
    dashWidth: dashWidth ?? 5,
    dashSpace: dashSpace ?? 3,
    borderRadius: radius ?? 0,
  );
}

/// 描边装饰
/// [color] 描边颜色
/// [strokeWidth] 描边宽度
/// [fillDecoration]
BoxDecoration strokeDecoration({
  Color? color,
  BuildContext? context,
  double strokeWidth = 1,
  double? radius = kDefaultBorderRadiusXX,
  BorderStyle style = BorderStyle.solid,
  double strokeAlign = BorderSide.strokeAlignInside,
  BorderSide? top,
  BorderSide? bottom,
  BorderSide? start,
  BorderSide? end,
  //--
  Color? fillColor,
}) {
  final strokeColor = color ?? GlobalTheme.of(context).accentColor;
  final BorderSide side = BorderSide(
    color: strokeColor,
    width: strokeWidth,
    style: style,
    strokeAlign: strokeAlign,
  );
  return BoxDecoration(
    color: fillColor,
    border: BorderDirectional(
      top: top ?? side,
      bottom: bottom ?? side,
      start: start ?? side,
      end: end ?? side,
    ),
    borderRadius: radius != null && radius > 0
        ? BorderRadius.all(Radius.circular(radius))
        : null,
  );
}

/// 线条描边装饰
BoxBorder strokeBorder({
  Color? color,
  BuildContext? context,
  double strokeWidth = 1,
  double borderRadius = kDefaultBorderRadiusXX,
  BorderStyle style = BorderStyle.solid,
  double strokeAlign = BorderSide.strokeAlignInside,
  BorderSide? top,
  BorderSide? bottom,
  BorderSide? left,
  BorderSide? right,
}) {
  final strokeColor = color ?? GlobalTheme.of(context).accentColor;
  final BorderSide side = BorderSide(
    color: strokeColor,
    width: strokeWidth,
    style: style,
    strokeAlign: strokeAlign,
  );
  return Border(
    top: top ?? side,
    bottom: bottom ?? side,
    left: left ?? side,
    right: right ?? side,
  );
}

/// 四条边都是线条的装饰器
BoxDecoration lineDecoration({
  BuildContext? context,
  Color? topLineColor,
  Color? bottomLineColor,
  Color? leftLineColor,
  Color? rightLineColor,
  double topLineWidth = 1,
  double bottomLineWidth = 1,
  double leftLineWidth = 1,
  double rightLineWidth = 1,
  BorderSide? topSide,
  BorderSide? bottomSide,
  BorderSide? leftSide,
  BorderSide? rightSide,
}) {
  final lineColor = GlobalTheme.of(context).lineColor;
  return BoxDecoration(
    border: Border(
      left:
          leftSide ??
          (leftLineWidth > 0
              ? BorderSide(
                  color: leftLineColor ?? lineColor,
                  width: leftLineWidth,
                )
              : BorderSide.none),
      top:
          topSide ??
          (topLineWidth > 0
              ? BorderSide(
                  color: topLineColor ?? lineColor,
                  width: topLineWidth,
                )
              : BorderSide.none),
      right:
          rightSide ??
          (rightLineWidth > 0
              ? BorderSide(
                  color: rightLineColor ?? lineColor,
                  width: rightLineWidth,
                )
              : BorderSide.none),
      bottom:
          bottomSide ??
          (bottomLineWidth > 0
              ? BorderSide(
                  color: bottomLineColor ?? lineColor,
                  width: bottomLineWidth,
                )
              : BorderSide.none),
    ),
  );
}

/// 下划线装饰
BoxDecoration underlineDecoration({
  BuildContext? context,
  Color? bottomLineColor,
  double bottomLineWidth = kM,
}) => lineDecoration(
  context: context,
  bottomLineColor: bottomLineColor ?? GlobalTheme.of(context).infoColor,
  bottomLineWidth: bottomLineWidth,
  leftLineWidth: 0,
  rightLineWidth: 0,
  topLineWidth: 0,
);

/// 纯色填充装饰, 支持圆角
/// [color] 填充颜色
/// [gradient] 渐变颜色.[linearGradient].[sweepGradientShader].[sweepGradientShader]
/// [strokeDecoration]
/// [border] 边框.[strokeBorder]
BoxDecoration fillDecoration({
  BuildContext? context,
  Color? color,
  Gradient? gradient,
  BorderRadiusGeometry? borderRadius,
  double? radius = kDefaultBorderRadiusXX,
  double? onlyLeftRadius,
  double? onlyRightRadius,
  double? onlyTopRadius,
  double? onlyBottomRadius,
  BoxBorder? border,
  //--
  List<BoxShadow>? boxShadow,
  Color? shadowColor,
  Offset shadowOffset = kShadowOffset,
  double shadowBlurRadius = kDefaultBlurRadius,
  double shadowSpreadRadius = kS,
}) {
  final fillColor = color ?? GlobalTheme.of(context).accentColor;

  if (borderRadius == null) {
    if (onlyTopRadius != null || onlyBottomRadius != null) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(onlyTopRadius ?? 0),
        topRight: Radius.circular(onlyTopRadius ?? 0),
        bottomLeft: Radius.circular(onlyBottomRadius ?? 0),
        bottomRight: Radius.circular(onlyBottomRadius ?? 0),
      );
    } else if (onlyLeftRadius != null || onlyRightRadius != null) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(onlyLeftRadius ?? 0),
        bottomLeft: Radius.circular(onlyLeftRadius ?? 0),
        topRight: Radius.circular(onlyRightRadius ?? 0),
        bottomRight: Radius.circular(onlyRightRadius ?? 0),
      );
    } else {
      borderRadius = BorderRadius.all(Radius.circular(radius ?? 0));
    }
  }

  return BoxDecoration(
    color: fillColor,
    gradient: gradient,
    borderRadius: borderRadius,
    border: border,
    boxShadow:
        boxShadow ??
        (shadowColor == null
            ? null
            : [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset, //阴影y轴偏移量
                  blurRadius: shadowBlurRadius, //阴影模糊程度
                  spreadRadius: shadowSpreadRadius, //阴影扩散程度
                ),
              ]),
    //gradient:
  );
}

/// 线性渐变装饰
/// [colors] 设置了渐变颜色, 则[fillColor]无效
/// [borderRadius] 圆角
BoxDecoration lineaGradientDecoration(
  List<Color>? colors, {
  BuildContext? context,
  Color? fillColor,
  double borderRadius = 0,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
}) {
  final color = fillColor ?? GlobalTheme.of(context).accentColor;
  return BoxDecoration(
    color: color,
    gradient: colors == null
        ? null
        : linearGradient(colors, begin: begin, end: end),
    borderRadius: borderRadius > 0
        ? BorderRadius.all(Radius.circular(borderRadius))
        : null,
    //gradient:
  );
}

/// 图片装饰
/// - [Decoration]->[BoxDecoration]
/// - [DecorationImage]
BoxDecoration imageDecoration(ImageProvider image, {BoxFit fit = BoxFit.fill}) {
  return BoxDecoration(
    image: DecorationImage(image: image, fit: fit),
  );
}

/// 画笔绘制装饰
/// [PaintDecoration]
PaintDecoration paintDecoration(PaintFn? paint) => PaintDecoration(paint);

/// 圆点装饰
/// - 默认红点装饰
BoxDecoration dotDecoration({BoxShape shape = .circle, Color? color}) {
  return BoxDecoration(shape: shape, color: color ?? Colors.redAccent);
}

//endregion BoxDecoration

//region InputDecoration

/// [ShapeBorder]->[InputBorder]
/// [InputBorder.none]
/// [BorderSide.none]
/// [InputDecoration]
/// [OutlineInputBorder]
///
/// - [outlineInputBorder]
/// - [underlineInputBorder]
OutlineInputBorder outlineInputBorder({
  BuildContext? context,
  Color? color,
  double width = 1,
  double gapPadding = 4,
  double? borderRadius,
  BorderSide? borderSide,
}) {
  final globalTheme = GlobalTheme.of(context);
  return OutlineInputBorder(
    borderRadius: borderRadius != null
        ? BorderRadius.circular(borderRadius)
        : BorderRadius.circular(kDefaultBorderRadiusXX),
    borderSide:
        borderSide ??
        BorderSide(color: color ?? globalTheme.borderColor, width: width),
    gapPadding: gapPadding,
  );
}

/// [InputDecoration]
/// [UnderlineInputBorder]
///
/// - [outlineInputBorder]
/// - [underlineInputBorder]
UnderlineInputBorder underlineInputBorder({
  BuildContext? context,
  Color? color,
  double width = 1,
  double borderRadius = 0,
}) {
  final globalTheme = GlobalTheme.of(context);
  return UnderlineInputBorder(
    borderSide: BorderSide(
      color: color ?? globalTheme.borderColor,
      width: width,
    ),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

//endregion InputDecoration
