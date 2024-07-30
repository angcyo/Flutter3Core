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

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  /// 限制内容场景的区域, 网格线只会在此区域内绘制
  ///
  /// 警示所有元素必须在此区域内
  ///
  /// [CanvasAxisManager.painting]
  /// [clipCanvasContent]
  @dp
  @sceneCoordinate
  ContentBoundsInfo? sceneContentBoundsInfo;

  /// 画布显示内容区域时, 要使用的跟随矩形信息,
  /// 不指定则会降级使用[sceneContentBoundsInfo]
  @dp
  @sceneCoordinate
  ContentBoundsInfo? sceneFollowRectInfo;

  /// 画布跟随时的显示区域, 同时也是元素分配位置的参考
  @dp
  @sceneCoordinate
  Rect? get canvasContentFollowRect => isCanvasComponentEnable
      ? (sceneFollowRectInfo?.bounds ?? sceneContentBoundsInfo?.bounds)
      : null;

  /// 场景内最佳区域范围, 应该在[sceneContentBoundsInfo]区域内
  /// 提示所有元素应该在此区域内
  @dp
  @sceneCoordinate
  @flagProperty
  ContentBoundsInfo? sceneBestBoundsInfo;

  /// 额外需要绘制的路径信息
  final List<PainterPathInfo> painterPathList = [];

  /// 额外画布内容绘制
  final List<IPainter> painterList = [];

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
      sceneContentBoundsInfo?.let((info) {
        final canvasStyle = canvasDelegate.canvasStyle;
        //场景背景绘制

        paintMeta.withPaintMatrix(canvas, () {
          //场景内容背景
          if (canvasStyle.sceneContentBgColor != null) {
            final paint = Paint()
              ..style = PaintingStyle.fill
              ..color = canvasStyle.sceneContentBgColor!;
            _drawBoundsInfo(canvas, paint, info);
          }

          //额外绘制的路径信息
          for (final pathInfo in painterPathList) {
            _paint.strokeWidth = pathInfo.strokeWidth / paintMeta.canvasScale;
            _paint.color = pathInfo.color;
            _paint.style =
                pathInfo.fill ? PaintingStyle.fill : PaintingStyle.stroke;
            canvas.drawPath(pathInfo.path, _paint);
          }

          //额外绘制内容
          for (final painter in painterList) {
            painter.painting(canvas, paintMeta);
          }

          //边界边框
          if (canvasStyle.paintSceneContentBounds == true) {
            _drawBoundsInfo(
              canvas,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = canvasStyle.axisPrimaryColor,
              info,
            );
          }
        });
      });
    });
  }

  /// 裁剪画布内容区域, 目前只裁剪了网格和内容背景, 元素不裁剪
  /// [CanvasAxisManager.painting]
  void clipCanvasContent(Canvas canvas, VoidAction action) {
    //debugger();
    final boundsInfo = sceneContentBoundsInfo;
    if (boundsInfo == null) {
      action();
    } else {
      if (boundsInfo.path != null) {
        canvas.withClipPath(
          canvasViewBox.toViewPath(boundsInfo.path!),
          () {
            action();
          },
        );
      } else if (boundsInfo.bounds != null) {
        canvas.withClipRect(
          canvasViewBox.toViewRect(boundsInfo.bounds!),
          () {
            action();
          },
        );
      } else {
        action();
      }
    }
  }

  //--

  void _drawBoundsInfo(
    Canvas canvas,
    Paint paint,
    ContentBoundsInfo boundsInfo,
  ) {
    if (boundsInfo.path != null) {
      canvas.drawPath(boundsInfo.path!, paint);
    } else if (boundsInfo.bounds != null) {
      canvas.drawRect(boundsInfo.bounds!, paint);
    }
  }

  //--

  /// 限制画布内容绘制区域, 背景只会在此区域绘制
  /// [onUpdateAction] 更新成功的回调
  void updateCanvasSceneContentBounds({
    @dp @sceneCoordinate ContentBoundsInfo? boundsInfo,
    @dp @sceneCoordinate Path? path,
    @dp @sceneCoordinate Rect? bounds,
    bool? showRect,
    bool? animate,
    VoidCallback? onUpdateAction,
  }) {
    if (boundsInfo == null && path == null && bounds == null) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return;
    }

    if (canvasDelegate.canvasViewBox.isCanvasBoxInitialize) {
      showRect ??= sceneContentBoundsInfo == null;
      sceneContentBoundsInfo = boundsInfo ??
          ContentBoundsInfo(
            path: path,
            bounds: bounds,
          );
      if (showRect && bounds != null) {
        canvasDelegate.showRect(
          rect: bounds,
          animate: animate,
        );
      }
      onUpdateAction?.call();
    } else {
      scheduleMicrotask(() {
        updateCanvasSceneContentBounds(
          boundsInfo: boundsInfo,
          path: path,
          bounds: bounds,
          showRect: showRect,
          animate: animate,
          onUpdateAction: onUpdateAction,
        );
      });
    }
  }

  /// 触发画布跟随
  void showCanvasSceneContentBounds({
    bool? animate,
    bool? enableZoomOut,
    bool? enableZoomIn,
  }) {
    canvasContentFollowRect?.let((it) {
      canvasDelegate.showRect(
        rect: it,
        animate: animate,
        enableZoomOut: enableZoomOut,
        enableZoomIn: enableZoomIn,
      );
    });
  }
}

/// 路径边界信息
class ContentBoundsInfo {
  /// 关键路径
  final Path? path;

  /// [path]路径的边界
  final Rect? bounds;

  ContentBoundsInfo({this.path, this.bounds});
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
