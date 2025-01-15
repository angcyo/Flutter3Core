part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/29
///
/// 画布跟随管理, 跟随场景, 跟随元素, 跟随画布, 跟随指定的矩形等
/// [CanvasDelegate]成员
class CanvasFollowManager with CanvasComponentMixin {
  final CanvasDelegate canvasDelegate;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasFollowManager(this.canvasDelegate);

  //region --配置属性--

  /// [margin] 矩形区域的外边距, 额外的外边距
  EdgeInsets? margin = const EdgeInsets.all(kXxh);

  /// [enableZoomOut] 是否允许视口缩小处理, 否则只有平移[rect]到视口中心的效果
  @Deprecated("请使用[fit]")
  bool enableZoomOut = true;

  /// [enableZoomIn] 是否允许视口放大处理, 否则只有平移[rect]到视口中心的效果
  @Deprecated("请使用[fit]")
  bool enableZoomIn = false;

  /// [animate] 是否动画改变
  bool animate = true;

  /// [awaitAnimate] 是否等待动画结束
  bool awaitAnimate = false;

  /// 对齐画布的位置
  /// [CanvasViewBox.canvasBounds]
  Alignment alignment = Alignment.center;

  /// 缩放模式
  /// [CanvasViewBox.canvasBounds]
  BoxFit fit = BoxFit.contain;

  /// 当设置过画布内容模版时, 所有的[followRect]操作是否都将平移量
  /// 设置为内容模板的位置?
  /// [CanvasContentManager.canvasContentFollowRectInner]
  @implementation
  bool? enableFollowContentTranslate;

  /// [enableFollowContentTranslate]
  @implementation
  bool get enableFollowContentTranslateInner {
    if (enableFollowContentTranslate != null) {
      return enableFollowContentTranslate!;
    }
    final contentRect =
        canvasDelegate.canvasContentManager.canvasContentFollowRectInner;
    if (contentRect == null) {
      return false;
    }
    if (alignment == Alignment.topCenter ||
        alignment == Alignment.topLeft ||
        alignment == Alignment.topRight) {
      return true;
    }
    return false;
  }

  //endregion --配置属性--

  /// 跟随画布内容模版
  /// [rollbackPainter] 当未指定内容模版时, 是否降级到元素边界
  /// [restoreDef] 当未指定场景内容时, 是否恢复默认的1:1视图?
  /// [CanvasContentManager.followCanvasContentTemplate]
  void followCanvasContent({
    bool rollbackPainter = true,
    bool? restoreDef,
    bool? animate,
    bool? awaitAnimate,
  }) {
    final sceneBounds = canvasDelegate
            .canvasPaintManager.contentManager.canvasContentFollowRectInner ??
        (rollbackPainter
            ? canvasDelegate.canvasElementManager.allElementsBounds
            : null);
    //debugger();
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
      followRect(
        sceneBounds,
        animate: animate,
        awaitAnimate: awaitAnimate,
        restoreDefault: restoreDef,
      );
    }
  }

  /// 跟随矩形
  /// 所有函数参数, 都只是临时生效的参数, 长久生效请使用属性
  @api
  @Deprecated("请使用[followRect]")
  void followRectOld(
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
        followRectOld(
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
    if (rect == null || rect.isEmpty) {
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
    final canvasSceneVisibleBounds = canvasViewBox.canvasSceneVisibleBounds;
    final canvasVisibleWidth = canvasSceneVisibleBounds.width;
    final canvasVisibleHeight = canvasSceneVisibleBounds.height;

    double sx = (canvasVisibleWidth / rect.width).ensureValid(1);
    double sy = (canvasVisibleHeight / rect.height).ensureValid(1);

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

  /// 跟随矩形
  /// 所有函数参数, 都只是临时生效的参数, 长久生效请使用属性
  /// [applyAlignRect]
  /// [applyAlignMatrix]
  ///
  /// [fit] 特殊情况, 当[fit]为[BoxFit.none]时,
  ///   如果当前缩放值, 已经能显示对应[rect], 则仅进行平移操作;
  ///   否则降级为默认的[CanvasFollowManager.fit]处理方式;
  ///   更多时候这个值应该为[BoxFit.contain].
  ///
  @api
  void followRect(
    @sceneCoordinate Rect? rect, {
    @viewCoordinate EdgeInsets? margin,
    Alignment? alignment,
    BoxFit? fit,
    bool? animate,
    bool? awaitAnimate,
    bool? restoreDefault /*当没有rect时, 是否恢复默认的100%*/,
  }) {
    //debugger();
    if (!canvasViewBox.isCanvasBoxInitialize) {
      //画布还没有初始化完成
      scheduleMicrotask(() {
        followRect(
          rect,
          alignment: alignment,
          margin: margin,
          fit: fit,
          animate: animate,
          awaitAnimate: awaitAnimate,
          restoreDefault: restoreDefault,
        );
      });
      return;
    }

    alignment ??= this.alignment;
    fit ??= this.fit;
    margin ??= this.margin;
    animate ??= this.animate;
    awaitAnimate ??= this.awaitAnimate;

    //default
    if (rect == null || rect.isEmpty) {
      if (restoreDefault == true) {
        if (!canvasDelegate.canvasPaintManager.contentManager
            .followCanvasContentTemplate()) {
          //模板跟随失败后, 则恢复默认
          canvasViewBox.changeMatrix(
            Matrix4.identity(),
            animate: animate,
            awaitAnimate: awaitAnimate,
          );
        }
      } else {
        assert(() {
          l.w('操作被忽略rect:$rect');
          return true;
        }());
      }
      return;
    }

    @viewCoordinate
    final canvasBounds = canvasViewBox.canvasBounds;
    @sceneCoordinate
    final canvasSceneVisibleBounds = canvasViewBox.canvasSceneVisibleBounds;
    final canvasVisibleWidth = canvasSceneVisibleBounds.width;
    final canvasVisibleHeight = canvasSceneVisibleBounds.height;

    @sceneCoordinate
    final toRect = rect;

    if (fit == BoxFit.none) {
      //特殊处理:
      if (canvasVisibleWidth > toRect.width &&
          canvasVisibleHeight > toRect.height) {
        //缩放比例已经足够显示目标, 则仅进行平移
        final sx = canvasViewBox.canvasMatrix.scaleX;
        final sy = canvasViewBox.canvasMatrix.scaleY;

        //目标最终显示在视图上的位置
        @viewCoordinate
        final targetViewLeft = toRect.left * sx;
        final targetViewTop = toRect.top * sy;
        final targetViewWidth = toRect.width * sx;
        final targetViewHeight = toRect.height * sy;

        //目标偏移到视图左上角需要进行的偏移
        final targetViewOffset = Offset(targetViewLeft, targetViewTop);

        //对齐之后的位置, 不包含偏移和自身的left/top
        //这一步主要计算元素[alignment]相对于视图的偏移
        @viewCoordinate
        final targetViewAlignmentOffset = alignment
            .inscribe(
              Size(targetViewWidth, targetViewHeight),
              Rect.fromLTWH(0, 0, canvasBounds.width, canvasBounds.height),
            )
            .lt;
        //margin的偏移
        @viewCoordinate
        final marginOffset = alignment.offset(margin);

        //debugger();

        final translateOffset =
            -targetViewOffset + targetViewAlignmentOffset + marginOffset;
        final translateMatrix = Matrix4.identity();
        //特殊处理: 内容顶部对齐时, follow统一排除顶部偏移
        translateMatrix.translateTo(
            x: translateOffset.dx,
            y: /*this.alignment.y == -1 ? 0 :*/ translateOffset.dy);

        final scaleMatrix = Matrix4.identity();
        scaleMatrix.scale(sx, sy);

        /*translateMatrix.translateTo(
            offset: targetRect.center - toRect.center + marginOffset);*/
        //debugger();

        final Matrix4 matrix = translateMatrix * scaleMatrix;
        /*if (enableFollowContentTranslateInner) {
          //debugger();
          final contentRect =
              canvasDelegate.canvasContentManager.canvasContentFollowRectInner;
          if (contentRect != null) {
            final originAlignment = this.alignment;
            if (originAlignment == Alignment.topCenter ||
                originAlignment == Alignment.topRight) {
              matrix.setTranslationRaw(
                matrix.translateX,
                contentRect.top,
                matrix.translateZ,
              );
            } else if (originAlignment == Alignment.topLeft) {
              matrix.setTranslationRaw(
                contentRect.left,
                contentRect.top,
                matrix.translateZ,
              );
            }
          }
        }*/
        canvasViewBox.changeMatrix(
          matrix,
          animate: animate,
          awaitAnimate: awaitAnimate,
        );
        return;
      } else {
        fit = this.fit;
      }
    }

    //margin 属性
    @viewCoordinate
    double marginLeft = margin?.left ?? 0,
        marginTop = margin?.top ?? 0,
        marginRight = margin?.right ?? 0,
        marginBottom = margin?.bottom ?? 0;

    @viewCoordinate
    final fromRect = Rect.fromLTWH(
        marginLeft,
        marginTop,
        canvasBounds.width - (marginLeft + marginRight),
        canvasBounds.height - (marginTop + marginBottom));

    final alignMatrix = applyAlignMatrix(fromRect.size, toRect.size,
        fit: fit,
        alignment: alignment,
        anchorOffset: Offset(toRect.left, toRect.top));

    //边距在此生效
    final translateMatrix = Matrix4.identity();
    translateMatrix.translate(
      -toRect.left + fromRect.left,
      -toRect.top + fromRect.top,
    );

    //debugger();

    canvasViewBox.changeMatrix(
      translateMatrix * alignMatrix,
      animate: animate,
      awaitAnimate: awaitAnimate,
    );
  }

  /// 测试
  @testPoint
  @implementation
  void testFollow() {
    alignment = Alignment.center;
    fit = BoxFit.contain;
    followRect(canvasDelegate
        .canvasPaintManager.contentManager.canvasContentFollowRectInner);
  }
}
