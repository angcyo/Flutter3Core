part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/29
///
/// 画布内容控制, 背景控制
/// 以及一些内容控制方面的配置信息
class CanvasContentManager extends IPainter with CanvasComponentMixin {
  final CanvasPaintManager paintManager;

  CanvasDelegate get canvasDelegate => paintManager.canvasDelegate;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  /// 限制内容场景的区域, 网格线只会在此区域内绘制
  @dp
  @sceneCoordinate
  Rect? sceneContentBounds;

  /// 画布跟随时需要采用的矩形坐标
  /// [sceneContentBounds]
  @dp
  @sceneCoordinate
  @flagProperty
  Rect? canvasShowSceneContentRect;

  /// 画布跟随时的显示区域, 同时也是元素分配位置的参考
  @dp
  @sceneCoordinate
  Rect? get showCanvasContentRect => isCanvasComponentEnable
      ? (canvasShowSceneContentRect ?? sceneContentBounds)
      : null;

  /// 额外需要绘制的路径信息
  final List<PainterPathInfo> painterPathList = [];

  CanvasContentManager(this.paintManager);

  /// 画笔
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.toDpFromPx();

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    if (!isCanvasComponentEnable) {
      return;
    }
    canvas.withClipRect(canvasDelegate.canvasViewBox.canvasBounds, () {
      //整体画布背景颜色绘制
      if (canvasStyle.canvasBgColor != null) {
        canvas.drawRect(
          canvasDelegate.canvasViewBox.canvasBounds,
          Paint()
            ..style = PaintingStyle.fill
            ..color = canvasStyle.canvasBgColor!,
        );
      }
      //场景内容提示绘制
      sceneContentBounds?.let((it) {
        final canvasStyle = canvasDelegate.canvasStyle;
        //场景背景绘制

        paintMeta.withPaintMatrix(canvas, () {
          //场景内容背景
          if (canvasStyle.sceneContentBgColor != null) {
            canvas.drawRect(
              it,
              Paint()
                ..style = PaintingStyle.fill
                ..color = canvasStyle.sceneContentBgColor!,
            );
          }

          //额外绘制的路径信息
          for (final pathInfo in painterPathList) {
            _paint.strokeWidth = pathInfo.strokeWidth / paintMeta.canvasScale;
            _paint.color = pathInfo.color;
            _paint.style =
                pathInfo.fill ? PaintingStyle.fill : PaintingStyle.stroke;
            canvas.drawPath(pathInfo.path, _paint);
          }

          //边界边框
          if (canvasStyle.paintSceneContentBounds == true) {
            canvas.drawRect(
              it,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = canvasStyle.axisPrimaryColor,
            );
          }
        });
      });
    });
  }

  //--

  /// 限制画布内容绘制区域, 背景只会在此区域绘制
  void updateCanvasSceneContentBounds(
    @dp @sceneCoordinate Rect? contentBounds, {
    bool? showRect,
  }) {
    if (canvasDelegate.canvasViewBox.isCanvasBoxInitialize) {
      showRect ??= sceneContentBounds == null;
      sceneContentBounds = contentBounds;
      if (showRect && contentBounds != null) {
        canvasDelegate.showRect(rect: contentBounds);
      }
    } else {
      scheduleMicrotask(() {
        updateCanvasSceneContentBounds(
          contentBounds,
          showRect: showRect,
        );
      });
    }
  }

  /// 触发画布跟随
  void showCanvasSceneContentBounds() {
    showCanvasContentRect?.let((it) {
      canvasDelegate.showRect(rect: it);
    });
  }
}

/// 需要绘制的路径信息
class PainterPathInfo {
  /// 要绘制的路径
  final Path path;

  /// 绘制路径的颜色
  final Color color;

  /// 是否填充
  final bool fill;

  /// 线宽
  final double strokeWidth;

  /// 标签, 用来自定义的标识
  @configProperty
  final String? tag;

  PainterPathInfo(
    this.path, {
    this.color = Colors.blue,
    this.fill = false,
    this.strokeWidth = 1,
    this.tag,
  });
}
