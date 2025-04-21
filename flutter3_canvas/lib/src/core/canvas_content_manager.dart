part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/29
///
/// 画布内容控制, 背景控制
/// 以及一些内容控制方面的配置信息
///
/// [CanvasPaintManager]的成员
///
class CanvasContentManager extends IPainter with CanvasComponentMixin {
  final CanvasPaintManager paintManager;

  CanvasDelegate get canvasDelegate => paintManager.canvasDelegate;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  bool get firstLayoutFollowTemplate => canvasStyle.firstLayoutFollowTemplate;

  //--

  /// 画布内容模版, 描述了内容大小, 最佳区域等信息
  /// [updateCanvasContentTemplate]
  /// [updateFillStyleContentTemplate]
  @configProperty
  CanvasContentTemplate? contentTemplate;

  /// 画布内容有效区域, 可以用来检测元素是否超出了有效区域
  /// [contentTemplate]
  @dp
  @sceneCoordinate
  Rect? get canvasContentBounds =>
      contentTemplate?.contentBackgroundInfo?.bounds;

  /// 画布内容最佳区域, 可以用来检测元素是否超出了最佳区域
  /// [contentTemplate]
  @dp
  @sceneCoordinate
  Rect? get canvasOptimumBounds => contentTemplate?.contentOptimumInfo?.bounds;

  //--

  /// 画布跟随时的显示区域, 同时也是元素分配位置的参考
  @dp
  @sceneCoordinate
  Rect? get canvasContentFollowRectInner =>
      isCanvasComponentEnable ? contentTemplate?.contentFollowRectInner : null;

  /// 画布最佳的元素中心点位置
  ///
  /// 当画布内容改变时, 请主动调用
  /// [CanvasDelegate.dispatchCanvasContentChanged]派发事件
  @dp
  @sceneCoordinate
  Offset? get canvasCenterInner =>
      canvasCenter ?? canvasContentFollowRectInner?.center;

  /// 画布中心点
  @dp
  @sceneCoordinate
  Offset? canvasCenter;

  //--

  /// 额外需要绘制的路径信息
  @configProperty
  final List<ContentPathPainterInfo> painterPathList = [];

  /// 额外画布内容绘制
  @configProperty
  final List<IPainter> painterList = [];

  CanvasContentManager(this.paintManager);

  /// [CanvasPaintManager.paint] 驱动
  /// 所有绘制内容都在元素底部
  /// [withCanvasContent]
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
      //画布内容模版
      contentTemplate?.let((template) {
        //场景背景绘制
        paintMeta.withPaintMatrix(canvas, () {
          //场景内容背景
          _drawPathPainterInfo(
            canvas,
            paintMeta.canvasScale,
            template.contentBackgroundInfo,
          );
          _drawPathPainterInfo(
            canvas,
            paintMeta.canvasScale,
            template.contentOptimumInfo,
          );

          //额外绘制的路径信息
          for (final pathInfo in painterPathList) {
            _drawPathPainterInfo(
              canvas,
              paintMeta.canvasScale,
              pathInfo,
            );
          }

          //额外绘制内容
          for (final painter in painterList) {
            painter.painting(canvas, paintMeta);
          }
        });

        //前景绘制
        _drawPathPainterInfo(
          canvas,
          paintMeta.canvasScale,
          template.contentForegroundInfo,
        );
      });
    });
  }

  /// 裁剪画布内容区域, 目前只裁剪了网格和内容背景, 元素不裁剪
  /// [CanvasAxisManager.painting]
  @callPoint
  @clipFlag
  void withCanvasContent(Canvas canvas, VoidAction action) {
    //debugger();
    final boundsInfo = contentTemplate?.contentBackgroundInfo;
    if (boundsInfo == null) {
      action();
    } else {
      if (boundsInfo.path != null) {
        final path = canvasViewBox.toViewPath(boundsInfo.path!);
        canvas.withClipPath(path, () {
          action();
        });
        if (canvasStyle.paintContentTemplateStroke) {
          canvas.drawPath(
              path,
              Paint()
                ..strokeWidth = canvasStyle.contentTemplateStrokeWidth
                ..color = canvasStyle.axisSecondaryColor
                ..style = PaintingStyle.stroke);
        }
      } else if (boundsInfo.rect != null) {
        final rect = canvasViewBox.toViewRect(boundsInfo.rect!);
        canvas.withClipRect(rect, () {
          action();
        });
        if (canvasStyle.paintContentTemplateStroke) {
          canvas.drawRect(
              rect,
              Paint()
                ..strokeWidth = canvasStyle.contentTemplateStrokeWidth
                ..color = canvasStyle.axisSecondaryColor
                ..style = PaintingStyle.stroke);
        }
      } else {
        action();
      }
    }
  }

  //--

  /// 将[ContentPathPainterInfo]描述的内容绘制出来
  void _drawPathPainterInfo(
    Canvas canvas,
    double canvasScale,
    ContentPathPainterInfo? info,
  ) {
    if (info == null) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.toDpFromPx();

    //
    void draw() {
      if (info.path != null) {
        canvas.drawPath(info.path!, paint);
      }
      if (info.rect != null) {
        canvas.drawRect(info.rect!, paint);
      }
    }

    //填充
    if (info.fill == true) {
      final fillColor =
          canvasDelegate.darkOr(info.fillColorDark, info.fillColor) ??
              info.fillColor;
      if (fillColor != null) {
        paint
          ..style = PaintingStyle.fill
          ..color = fillColor;
        draw();
      }
    }

    //描边
    if ((info.strokeWidth ?? 0) > 0) {
      final strokeColor =
          canvasDelegate.darkOr(info.strokeColorDark, info.strokeColor) ??
              info.strokeColor;
      if (strokeColor != null) {
        paint
          ..style = PaintingStyle.stroke
          ..color = strokeColor
          ..strokeWidth = info.strokeWidth! / canvasScale;
        draw();
      }
    }
  }

  //--

  /// 跟随画布模板限制的内容
  /// @return true: 跟随成功; false: 跟随失败
  /// [CanvasFollowManager.followCanvasContent]
  bool followCanvasContentTemplate({
    @dp @sceneCoordinate @indirectProperty Rect? rect,
    bool? animate,
    BoxFit? fit,
    VoidCallback? onUpdateAction,
    bool? restoreDefault,
  }) {
    rect ??= canvasContentFollowRectInner;
    if (restoreDefault != true && rect == null) {
      assert(() {
        l.w("无效的操作[followCanvasContentTemplate]->rect is null!");
        return true;
      }());
      return false;
    }
    if (canvasDelegate.canvasViewBox.isCanvasBoxInitialize) {
      canvasDelegate.followRect(
        rect: rect,
        animate: animate,
        fit: fit,
      );
      onUpdateAction?.call();
      return true;
    } else {
      scheduleMicrotask(() {
        followCanvasContentTemplate(
          rect: rect,
          animate: animate,
          fit: fit,
          onUpdateAction: onUpdateAction,
        );
      });
      return true;
    }
  }

  /// 更新填充样式的内容模版
  @api
  void updateFillStyleContentTemplate({
    @dp @sceneCoordinate Path? contentPath,
    @dp @sceneCoordinate Rect? contentRect,
    @dp @sceneCoordinate Rect? contentFollowRect,
    Color? contentFillColor,
    //--
    @dp @sceneCoordinate Path? optimumPath,
    @dp @sceneCoordinate Rect? optimumRect,
    Color? optimumFillColor,
    //--
    bool followRect = true,
    bool? animate,
  }) {
    //debugger();
    contentTemplate ??= CanvasContentTemplate();
    //content
    contentTemplate!.contentFollowRect = contentFollowRect;
    contentTemplate!.contentBackgroundInfo ??= ContentPathPainterInfo();
    contentTemplate!.contentBackgroundInfo!
      ..fill = true
      ..strokeWidth = 0
      ..path = contentPath
      ..rect = contentRect;
    contentTemplate!.contentBackgroundInfo?.fillColor =
        contentFillColor ?? contentTemplate!.contentBackgroundInfo!.fillColor;

    //optimum
    if (optimumPath != null || optimumRect != null) {
      contentTemplate!.contentOptimumInfo ??= ContentPathPainterInfo();
      contentTemplate!.contentOptimumInfo!
        ..fill = true
        ..strokeWidth = 0
        ..path = optimumPath
        ..rect = optimumRect;
      contentTemplate!.contentOptimumInfo?.fillColor =
          optimumFillColor ?? contentTemplate!.contentOptimumInfo!.fillColor;
    }
    if (followRect == true) {
      followCanvasContentTemplate(animate: animate);
    }
  }

  /// 直接更新画布模板数据
  @api
  void updateCanvasContentTemplate(
    CanvasContentTemplate? template, {
    bool followRect = true,
    bool? animate,
  }) {
    //debugger();
    contentTemplate = template;
    if (template != null && followRect == true) {
      followCanvasContentTemplate(animate: animate);
    }
  }

  /// 限制画布内容绘制区域, 背景只会在此区域绘制
  /// [boundsInfo] 边界信息
  /// [path].[bounds]->[boundsInfo]
  /// [onUpdateAction] 更新成功的回调
/*void updateCanvasSceneContentBounds({
    @dp @sceneCoordinate @indirectProperty Path? path,
    @dp @sceneCoordinate @indirectProperty Rect? bounds,
    bool? followRect,
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
      followRect ??= sceneContentBoundsInfo == null;
      sceneContentBoundsInfo = boundsInfo ??
          ContentTemplateInfo(
            path: path,
            rect: bounds,
          );
      if (followRect && bounds != null) {
        canvasDelegate.followRect(
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
          followRect: followRect,
          animate: animate,
          onUpdateAction: onUpdateAction,
        );
      });
    }
  }*/
}

/// 需要绘制的路径信息
class ContentPathPainterInfo {
  //--边界信息

  /// 要绘制的路径, 有值时, 就绘制
  @configProperty
  Path? path;

  /// [path]的边界缓存
  @autoInjectMark
  Rect? pathBoundsCache;

  /// 要绘制的矩形, 有值时, 就绘制
  @configProperty
  Rect? rect;

  /// 边界信息
  @output
  Rect? get bounds {
    if (rect != null) {
      return rect;
    }
    if (pathBoundsCache != null) {
      return pathBoundsCache;
    }
    return pathBoundsCache ??= path?.getExactBounds();
  }

  //--绘制信息

  /// 绘制路径的描边颜色, 不指定, 不绘制
  @configProperty
  Color? strokeColor;

  /// [strokeColor]
  @configProperty
  Color? strokeColorDark;

  /// 绘制路径的填充颜色, 不指定, 不绘制
  @configProperty
  Color? fillColor;

  /// [fillColor]
  @configProperty
  Color? fillColorDark;

  /// 是否填充
  @configProperty
  bool? fill;

  /// 线宽, <=0表示不绘制线框
  @configProperty
  double? strokeWidth;

  //--标识信息

  /// 标签, 用来自定义的标识
  @configProperty
  String? tag;

  ContentPathPainterInfo({
    this.path,
    this.pathBoundsCache,
    this.rect,
    this.strokeColor/*= Colors.blue*/,
    this.strokeColorDark,
    this.fillColor/*= const Color(0xfff5f5f5)*/,
    this.fillColorDark,
    this.fill = false,
    this.strokeWidth = 1,
    this.tag,
  });
}
