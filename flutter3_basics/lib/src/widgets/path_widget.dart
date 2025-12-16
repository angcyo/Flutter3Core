part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/08
///
/// [Path]路径绘制小部件
class PathWidget extends LeafRenderObjectWidget {
  /// The path to render.
  final Path? path;

  /// 多个路径
  final List<Path>? pathList;

  final ui.PaintingStyle style;

  /// The fill color to use when rendering the path.
  final Color color;

  final BoxFit fit;

  final Alignment alignment;

  /// 着色器
  final Shader? shader;

  /// 绘制填充的大小
  final EdgeInsets? padding;

  final double strokeWidth;

  const PathWidget({
    super.key,
    this.path,
    this.pathList,
    this.style = ui.PaintingStyle.stroke,
    this.color = Colors.black,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.shader,
    this.padding,
    this.strokeWidth = 0,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => PathRenderBox(
    pathList: pathList ?? (path != null ? [path!] : null),
    style: style,
    color: color,
    fit: fit,
    alignment: alignment,
    shader: shader,
    padding: padding,
    strokeWidth: strokeWidth,
  );

  @override
  void updateRenderObject(BuildContext context, PathRenderBox renderObject) {
    renderObject
      ..updatePath(pathList ?? (path != null ? [path!] : null))
      ..style = style
      ..color = color
      ..fit = fit
      ..alignment = alignment
      ..shader = shader
      ..padding = padding
      ..strokeWidth = strokeWidth
      ..markNeedsPaint();
  }
}

class PathRenderBox extends RenderBox {
  /// The path to render.
  List<Path>? pathList;

  ui.PaintingStyle style;

  /// The fill color to use when rendering the path.
  Color color;

  double strokeWidth;

  BoxFit fit;

  Alignment alignment;

  /// 着色器
  Shader? shader;

  Rect? _pathBounds;

  /// 绘制填充的大小
  EdgeInsets? padding;

  PathRenderBox({
    this.pathList,
    this.style = ui.PaintingStyle.stroke,
    this.color = Colors.black,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.shader,
    this.padding,
    this.strokeWidth = 0,
  });

  void updatePath(List<Path>? newPathList) {
    //debugger();
    if (pathList != newPathList) {
      _pathBounds = null;
    }
    pathList = newPathList;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    //debugger();
    if (pathList != null) {
      _pathBounds ??= pathList!.getExactBounds();
      final pathSize = _pathBounds!.size;
      assert(() {
        if (pathSize.isEmpty) {
          l.w("path size isEmpty!");
        }
        return true;
      }());
      if (constraints.isTight) {
        //有一种满意的约束尺寸
        size = constraints.smallest;
      } else {
        size = constraints.constrain(pathSize);
      }
    } else {
      size = constraints.constrain(Size.zero);
      debugger();
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    if (pathList != null) {
      final canvas = context.canvas;
      canvas.drawPathIn(
        pathList,
        _pathBounds,
        offset & size,
        fit: fit,
        alignment: alignment,
        dstPadding: padding,
        paint: Paint()
          ..color = color
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = shader
          ..strokeWidth = strokeWidth
          ..style = style,
      );
    }
  }
}

//--

class PathRegionInfo {
  /// 是否精确命中
  final bool isExactHit;

  /// 需要绘制的路径
  final Path? path;

  /// 填充绘制的颜色, 有值就绘制
  final Color? fillColor;

  /// 按下时的填充颜色
  @defInjectMark
  final Color? downFillColor;

  /// 描边绘制的颜色, 有值就绘制
  final Color? strokeColor;

  /// 按下时的描边颜色
  @defInjectMark
  final Color? downStrokeColor;

  /// 描边的宽度
  final double strokeWidth;

  /// 点击事件
  final VoidCallback? onTap;

  //--paint

  /// 背景绘制信息
  final void Function(Canvas canvas, PathRegionInfo regionInfo)?
  onBackgroundPaint;

  /// 前景绘制信息
  final void Function(Canvas canvas, PathRegionInfo regionInfo)?
  onForegroundPaint;

  //--text

  /// 在这个[boundsCache]区域需要绘制的文本信息
  final String? text;
  final Color textColor;
  final Color? downTextColor;
  final double fontSize;
  final Alignment textAlignment;
  final Offset textOffset;

  // --cache
  Rect? boundsCache;
  bool isPointerDown;

  PathRegionInfo({
    this.isExactHit = true,
    this.path,
    this.fillColor,
    this.downFillColor,
    this.strokeColor = Colors.black,
    this.downStrokeColor,
    this.strokeWidth = 1.0,
    this.onTap,
    //--
    this.onBackgroundPaint,
    this.onForegroundPaint,
    //--
    this.text,
    this.textColor = Colors.black,
    this.downTextColor,
    this.fontSize = kDefaultFontSize,
    this.textAlignment = Alignment.center,
    this.textOffset = Offset.zero,
    //--
    this.boundsCache,
    this.isPointerDown = false,
  });
}

/// [Path]路径区域绘制小部件
/// 支持绘制n个[Path]并且支持事件响应
class PathRegionWidget extends LeafRenderObjectWidget {
  /// 绘制区域, 类似于svg的view box, 影响小部件测量时的大小
  final Rect? viewBox;

  /// 核心路径区域信息
  final List<PathRegionInfo>? regionInfoList;

  //--

  /// 检查命中元素时, 是否倒序
  final bool reverseHitTest;

  /// 命中时, 颜色增加的亮度
  final double hitAddBrightness;

  const PathRegionWidget({
    super.key,
    this.viewBox,
    this.reverseHitTest = false,
    this.regionInfoList,
    this.hitAddBrightness = 10.0,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      PathRegionRenderBox(this);

  @override
  void updateRenderObject(
    BuildContext context,
    PathRegionRenderBox renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..config = this
      ..markNeedsLayout();
  }
}

class PathRegionRenderBox extends RenderBox {
  PathRegionWidget config;

  PathRegionRenderBox(this.config);

  @override
  void performLayout() {
    final constraints = this.constraints;
    if (config.viewBox == null) {
      size = constraints.biggest;
    } else {
      size = constraints.constrain(config.viewBox!.size);
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    final canvas = context.canvas;
    canvas.withTranslate(offset.dx, offset.dy, () {
      for (final item in config.regionInfoList ?? <PathRegionInfo>[]) {
        if (item.path != null) {
          item.boundsCache ??= item.path!.getExactBounds();
          //--
          item.onBackgroundPaint?.call(canvas, item);
          if (item.fillColor != null) {
            canvas.drawPath(
              item.path!,
              Paint()
                ..color = item.isPointerDown
                    ? item.downFillColor ??
                          item.fillColor!.addBrightness(config.hitAddBrightness)
                    : item.fillColor!
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..style = PaintingStyle.fill,
            );
          }
          //--
          if (item.strokeColor != null) {
            canvas.drawPath(
              item.path!,
              Paint()
                ..color = item.isPointerDown
                    ? item.downStrokeColor ??
                          item.strokeColor!.addBrightness(
                            config.hitAddBrightness,
                          )
                    : item.strokeColor!
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..strokeWidth = item.strokeWidth
                ..style = PaintingStyle.stroke,
            );
          }
          //--
          if (item.text != null) {
            canvas.drawText(
              item.text!,
              textColor: item.isPointerDown
                  ? item.downTextColor ?? item.textColor
                  : item.textColor,
              fontSize: item.fontSize,
              bounds: item.boundsCache,
              alignment: item.textAlignment,
              offset: item.textOffset,
            );
          }
          //--
          item.onForegroundPaint?.call(canvas, item);
        }
      }
    });
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }

  Iterable<PathRegionInfo> get _hitTestList =>
      (config.reverseHitTest
          ? config.regionInfoList?.reversed
          : config.regionInfoList) ??
      <PathRegionInfo>[];

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerDownEvent) {
      cancelPointerDown();
    }
    for (final item in _hitTestList) {
      if (event is PointerDownEvent) {
        item.boundsCache ??= item.path!.getExactBounds();
        if (item.onTap != null) {
          item.isPointerDown = item.isExactHit
              ? item.path?.contains(event.localPosition) == true
              : item.boundsCache?.contains(event.localPosition) == true;
          if (item.isPointerDown) {
            markNeedsPaint();
            break;
          }
        }
      } else if (event is PointerUpEvent) {
        if (item.isPointerDown == true) {
          item.onTap?.call();
          markNeedsPaint();
          break;
        }
      } else if (event.isPointerFinish) {
        item.isPointerDown = false;
        markNeedsPaint();
      }
    }
    if (event.isPointerFinish) {
      cancelPointerDown();
    }
  }

  /// 取消所有手势按下状态
  void cancelPointerDown() {
    for (final item in config.regionInfoList ?? <PathRegionInfo>[]) {
      item.isPointerDown = false;
    }
  }

  /// 查找手势按下时在的[PathRegionInfo]区域
  PathRegionInfo? findPathRegionInfo(Offset localPosition) {
    for (final item in config.regionInfoList ?? <PathRegionInfo>[]) {
      if (item.path != null) {
        if (item.path!.contains(localPosition)) {
          return item;
        }
      }
    }
    return null;
  }
}
