part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/29
///
/// 画布跟随管理, 跟随场景, 跟随元素, 跟随画布, 跟随指定的矩形等
class CanvasFollowManager with CanvasComponentMixin {
  final CanvasDelegate canvasDelegate;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasFollowManager(this.canvasDelegate);

  //region --配置属性--

  /// [margin] 矩形区域的外边距, 额外的外边距
  EdgeInsets? margin = const EdgeInsets.all(kXxh);

  /// [enableZoomOut] 是否允许视口缩小处理, 否则只有平移[rect]到视口中心的效果
  bool enableZoomOut = true;

  /// [enableZoomIn] 是否允许视口放大处理, 否则只有平移[rect]到视口中心的效果
  bool enableZoomIn = false;

  /// [animate] 是否动画改变
  bool animate = true;

  /// [awaitAnimate] 是否等待动画结束
  bool awaitAnimate = false;

  /// 对齐画布的位置
  /// [CanvasViewBox.canvasBounds]
  Alignment alignment = Alignment.center;

  //endregion --配置属性--

  /// 跟随场景内容
  /// [restoreDef] 当未指定场景内容时, 是否恢复默认的1:1视图?
  void followSceneContent({
    bool? restoreDef,
    bool? animate,
    bool? awaitAnimate,
  }) {
    //debugger();
    final sceneBounds = canvasDelegate
        .canvasPaintManager.contentManager.canvasContentFollowRect;
    if (sceneBounds == null) {
      if (restoreDef == true) {
        animate ??= this.animate;
        awaitAnimate ??= this.awaitAnimate;
        canvasViewBox.changeMatrix(
          Matrix4.identity(),
          animate: animate,
          awaitAnimate: awaitAnimate,
        );
      }
    } else {
      followRect(sceneBounds);
    }
  }

  /// 跟随矩形
  /// 所有函数参数, 都只是临时生效的参数, 长久生效请使用属性
  @api
  void followRect(
    @sceneCoordinate Rect? rect, {
    EdgeInsets? margin,
    Alignment? alignment,
    bool? enableZoomOut /*是否允许视口缩小处理*/,
    bool? enableZoomIn /*是否允许视口放大处理*/,
    bool? animate,
    bool? awaitAnimate,
    bool? restoreDefault /*当没有rect时, 是否恢复默认的100%*/,
  }) {
    if (!canvasViewBox.isCanvasBoxInitialize) {
      //画布还没有初始化完成
      scheduleMicrotask(() {
        followRect(
          rect,
          alignment: alignment,
          margin: margin,
          enableZoomOut: enableZoomOut,
          enableZoomIn: enableZoomIn,
          animate: animate,
          awaitAnimate: awaitAnimate,
          restoreDefault: restoreDefault,
        );
      });
      return;
    }

    //debugger();

    alignment ??= this.alignment;
    margin ??= this.margin;
    enableZoomOut ??= this.enableZoomOut;
    enableZoomIn ??= this.enableZoomIn;
    animate ??= this.animate;
    awaitAnimate ??= this.awaitAnimate;

    //default
    if (rect == null) {
      if (restoreDefault == true) {
        canvasViewBox.changeMatrix(
          Matrix4.identity(),
          animate: animate,
          awaitAnimate: awaitAnimate,
        );
      }
      return;
    }

    @viewCoordinate
    final canvasBounds = canvasViewBox.canvasBounds;
    @sceneCoordinate
    final canvasVisibleBounds = canvasViewBox.canvasVisibleBounds;
    final canvasVisibleWidth = canvasVisibleBounds.width;
    final canvasVisibleHeight = canvasVisibleBounds.height;

    double sx = canvasVisibleWidth / rect.width;
    double sy = canvasVisibleHeight / rect.height;

    //debugger();

    //缩放操作的锚点
    Offset anchor = Offset.zero;

    //平移矩阵
    final translateMatrix = Matrix4.identity();

    //margin 属性
    double marginLeft = margin?.left ?? 0,
        marginTop = margin?.top ?? 0,
        marginRight = margin?.right ?? 0,
        marginBottom = margin?.bottom ?? 0;

    //alignment 属性
    if (alignment == Alignment.center) {
      //在中心点开始缩放
      if (margin != null) {
        //debugger();
        marginLeft = margin.left / sx;
        marginTop = margin.top / sy;
        marginRight = margin.right / sx;
        marginBottom = margin.bottom / sy;
        rect = rect.inflateValue(EdgeInsets.only(
          left: marginLeft,
          top: marginTop,
          right: marginRight,
          bottom: marginBottom,
        ));
        sx = canvasBounds.width / rect.width;
        sy = canvasBounds.height / rect.height;
      }

      anchor = rect.center;

      final canvasCenter =
          Offset(canvasBounds.width / 2, canvasBounds.height / 2);
      final offset = canvasCenter - rect.center;
      translateMatrix.translate(offset.dx, offset.dy);
    } else if (alignment == Alignment.topLeft) {
      //debugger();
      //anchor = Offset(marginLeft, marginTop);

      final targetWidth = rect.width + marginLeft + marginRight;
      final targetHeight = rect.height + marginTop + marginBottom;

      sx = canvasBounds.width / targetWidth;
      sy = canvasBounds.height / targetHeight;
    }

    //handle
    double? scale;
    //debugger();
    if (enableZoomOut &&
        (rect.width > canvasVisibleWidth ||
            rect.height > canvasVisibleHeight)) {
      //元素比画布大, 此时画布需要缩小
      scale = min(sx, sy);
    } else if (enableZoomIn &&
        (rect.width < canvasVisibleWidth ||
            rect.height < canvasVisibleHeight)) {
      //元素比画布小, 此时画布需要放大
      scale = max(sx, sy);
    }

    final afterTranslateMatrix = Matrix4.identity();

    if (alignment == Alignment.topLeft) {
      //debugger();
      //anchor = Offset(marginLeft / (scale ?? 1.0), marginTop / (scale ?? 1.0));
      //translateMatrix.translate(-anchor.dx, -anchor.dy);
      anchor = Offset.zero;
      afterTranslateMatrix.translate(marginLeft, marginTop);
    }

    final scaleMatrix = createScaleMatrix(
      sx: scale ?? canvasViewBox.scaleX,
      sy: scale ?? canvasViewBox.scaleY,
      anchor: anchor,
    );
    canvasViewBox.changeMatrix(
      translateMatrix * scaleMatrix * afterTranslateMatrix,
      animate: animate,
      awaitAnimate: awaitAnimate,
    );
  }

  /// 测试
  @testPoint
  @implementation
  void testFollow() {
    alignment = Alignment.center;
    enableZoomIn = true;
    followRect(canvasDelegate
        .canvasPaintManager.contentManager.canvasContentFollowRect);
  }
}
