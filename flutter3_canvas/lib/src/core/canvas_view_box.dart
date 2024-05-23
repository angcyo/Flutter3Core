part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
/// 视图盒子, 用来限制画布的最小/最大平移/缩放的值
/// 未特殊说明, 所有可绘制的数值, 都是dp单位
class CanvasViewBox with DiagnosticableTreeMixin, DiagnosticsMixin {
  final CanvasDelegate canvasDelegate;

  CanvasViewBox(this.canvasDelegate);

  //region ---属性---

  /// 整个可绘制的区域, 包含坐标尺区域和内容区域以及其他空隙区域
  /// [updatePaintBounds] 在此方法中会更新此值
  @dp
  @viewCoordinate
  Rect paintBounds = Rect.zero;

  /// 内容绘制的区域, 在[paintBounds]中
  /// [updatePaintBounds] 在此方法中会更新此值
  @dp
  @viewCoordinate
  Rect canvasBounds = Rect.zero;

  /// 绘制的原点, 在[canvasBounds]中的偏移位置
  double originX = 0;
  double originY = 0;

  /// 获取绘图原点相对于视图左上角的偏移
  @viewCoordinate
  Offset get originOffset =>
      Offset(canvasBounds.left + originX, canvasBounds.top + originY);

  /// 绘制画布内容时, 需要偏移到画布定义的原点位置
  /// [canvasMatrix]
  Matrix4 get originMatrix =>
      Matrix4.identity()..translate(originOffset.dx, originOffset.dy);

  /// 绘制矩阵, 包含画布的缩放/平移数据
  Matrix4 canvasMatrix = Matrix4.identity();

  double get scaleX => canvasMatrix.scaleX;

  double get scaleY => canvasMatrix.scaleY;

  double get translateX => canvasMatrix.translateX;

  double get translateY => canvasMatrix.translateY;

  /// 当前场景可视的区域
  @sceneCoordinate
  Rect get canvasVisibleBounds => toSceneRect(canvasBounds);

  //endregion ---属性---

  //region ---限制---

  /// 最小/最大缩放比例
  double minScaleX = 0.1;
  double minScaleY = 0.1;
  double maxScaleX = 10;
  double maxScaleY = 10;

  /// 最小/最大平移值
  double minTranslateX = double.negativeInfinity;
  double minTranslateY = double.negativeInfinity;
  double maxTranslateX = double.infinity;
  double maxTranslateY = double.infinity;

  //endregion ---限制---

  /// 更新整个绘制区域大小, 顺便更新内容绘制区域
  @entryPoint
  void updatePaintBounds(Size size, bool isInitialize) {
    paintBounds = Offset.zero & size;

    final axisManager = canvasDelegate.canvasPaintManager.axisManager;
    canvasBounds = Rect.fromLTRB(
      paintBounds.left + axisManager.yAxisWidth,
      paintBounds.top + axisManager.yAxisWidth,
      paintBounds.right,
      paintBounds.bottom,
    );

    if (isInitialize) {
      postCallback(() {
        canvasDelegate.dispatchCanvasViewBoxChanged(this, isInitialize, true);
      });
    } else {
      canvasDelegate.dispatchCanvasViewBoxChanged(this, isInitialize, true);
    }
  }

  //region ---api---

  /// 获取场景原点相对于视图坐标的位置
  @viewCoordinate
  Offset get sceneOrigin => toViewPoint(Offset.zero);

  /// 将当前相对于视图的坐标, 偏移成相对于场景的坐标
  @viewCoordinate
  Offset offsetToSceneOriginPoint(@viewCoordinate Offset point) {
    return point - originOffset;
  }

  @viewCoordinate
  Rect offsetToSceneOriginRect(@viewCoordinate Rect rect) {
    return rect - originOffset;
  }

  /// 将视图坐标转换为场景内部坐标
  /// [isSceneOrigin] 表示[point]是否是相对于场景原点的坐标
  @sceneCoordinate
  @api
  Offset toScenePoint(@viewCoordinate Offset point,
      {bool isSceneOrigin = false}) {
    return canvasMatrix
        .invertedMatrix()
        .mapPoint(isSceneOrigin ? point : offsetToSceneOriginPoint(point));
  }

  @sceneCoordinate
  @api
  Rect toSceneRect(@viewCoordinate Rect rect, {bool isSceneOrigin = false}) {
    return canvasMatrix
        .invertedMatrix()
        .mapRect(isSceneOrigin ? rect : offsetToSceneOriginRect(rect));
  }

  /// 将当前相对于场景原点的坐标, 偏移成相对于视图左上角的坐标
  @viewCoordinate
  Offset offsetToViewOriginPoint(@viewCoordinate Offset point) {
    return point + originOffset;
  }

  @viewCoordinate
  Rect offsetToViewOriginRect(@viewCoordinate Rect rect) {
    return rect + originOffset;
  }

  /// 将场景内的坐标, 转换成视图坐标
  @viewCoordinate
  @api
  Offset toViewPoint(@sceneCoordinate Offset point) {
    return offsetToViewOriginPoint(canvasMatrix.mapPoint(point));
  }

  @viewCoordinate
  @api
  Rect toViewRect(@sceneCoordinate Rect rect) {
    return offsetToViewOriginRect(canvasMatrix.mapRect(rect));
  }

  //endregion ---api---

  //region ---操作---

  /// 限制matrix, min/max值
  /// [canvasMatrix]
  Matrix4 _checkMatrix(Matrix4 matrix) {
    final scaleX = matrix.scaleX.clamp(minScaleX, maxScaleX);
    final scaleY = matrix.scaleY.clamp(minScaleY, maxScaleY);
    final translateX = matrix.translateX.clamp(minTranslateX, maxTranslateX);
    final translateY = matrix.translateY.clamp(minTranslateY, maxTranslateY);
    /*canvasMatrix.setValues(scaleX, 0, 0, 0, 0, scaleY, 0, 0, 0, 0, 1, 0,
        translateX, translateY, 0, 1);*/
    matrix.scaleTo(sx: scaleX, sy: scaleY);
    matrix.translateTo(x: translateX, y: translateY);
    return matrix;
  }

  //--
  AnimationController? _lastAnimationController;
  Completer<bool>? _changeMatrixCompleter;

  /// 改变画布矩阵, 支持动画
  Future<bool> changeMatrix(
    Matrix4 target, {
    bool animate = true,
    void Function(bool isCompleted)? completedAction,
  }) async {
    _lastAnimationController?.dispose();
    _lastAnimationController = null;
    if (animate) {
      if (_changeMatrixCompleter == null ||
          _changeMatrixCompleter?.isCompleted == true) {
        _changeMatrixCompleter = Completer();
      }
      final matrixTween =
          Matrix4Tween(begin: canvasMatrix, end: _checkMatrix(target));
      _lastAnimationController =
          animation(canvasDelegate, (value, isCompleted) {
        final matrix = matrixTween.lerp(value);
        canvasMatrix.setFrom(matrix);
        completedAction?.call(isCompleted);
        canvasDelegate.dispatchCanvasViewBoxChanged(this, false, isCompleted);
        //--
        if (_changeMatrixCompleter?.isCompleted == true) {
        } else {
          _changeMatrixCompleter?.complete(isCompleted);
        }
        _changeMatrixCompleter = null;
      });
      return _changeMatrixCompleter!.future;
    } else {
      canvasMatrix.setFrom(_checkMatrix(target));
      completedAction?.call(true);
      canvasDelegate.dispatchCanvasViewBoxChanged(this, false, true);
    }
    //canvasMatrix.clone();
    //canvasMatrix.setFrom(arg)
    //canvasMatrix.multiply(target);
    //_checkMatrix();
    //canvasDelegate.dispatchCanvasViewBoxChanged(this);
    //Matrix4Tween(begin: begin!.matrix4, end: end!.matrix4).lerp(t)
    return true;
  }

  /// 平移画布
  @api
  void translateBy(double tx, double ty, {bool anim = true}) {
    assert(() {
      l.d('平移画布by: tx:$tx ty:$ty');
      return true;
    }());
    changeMatrix(canvasMatrix.clone()..translateBy(dx: tx, dy: ty),
        animate: anim);
  }

  /// 平移画布
  @api
  void translateTo(double tx, double ty, {bool anim = true}) {
    assert(() {
      l.d('平移画布to: tx:$tx tx:$ty');
      return true;
    }());
    changeMatrix(canvasMatrix.clone()..translateTo(x: tx, y: ty),
        animate: anim);
  }

  /// 使用比例缩放画布
  /// [pivot] 缩放的锚点
  @api
  void scaleBy({
    double? sx,
    double? sy,
    Offset? pivot,
    bool anim = true,
  }) {
    if (sx != null) {
      if ((sx < 1 && scaleX <= minScaleX) || (sx > 1 && scaleX >= maxScaleX)) {
        //已经达到了最小/最大, 还想缩放/放大
        return;
      }
    }

    if (sy != null) {
      if ((sy < 1 && scaleY <= minScaleY) || (sy > 1 && scaleY >= maxScaleY)) {
        //已经达到了最小/最大, 还想缩放/放大
        return;
      }
    }

    final matrix = canvasMatrix.clone()
      ..scaleBy(
        sx: sx,
        sy: sy,
        pivotX: pivot?.dx ?? 0,
        pivotY: pivot?.dy ?? 0,
      );
    assert(() {
      l.d('缩放画布by: sx:$sx sy:$sy pivot:$pivot anim:$anim');
      return true;
    }());
    changeMatrix(matrix, animate: anim);
  }

  /// 使用指定比例缩放画布
  @api
  void scaleTo({
    double? sx,
    double? sy,
    Offset? pivot,
    bool anim = true,
  }) {
    assert(() {
      l.d('缩放画布to: sx:$sx sy:$sy');
      return true;
    }());
    changeMatrix(
        canvasMatrix.clone()
          ..scaleTo(
            sx: sx,
            sy: sy,
            pivotX: pivot?.dx ?? 0,
            pivotY: pivot?.dy ?? 0,
          ),
        animate: anim);
  }

//endregion ---操作---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Rect>('paintBounds', paintBounds))
      ..add(DiagnosticsProperty<Rect>('canvasBounds', canvasBounds))
      ..add(DiagnosticsProperty<Offset>('originOffset', originOffset))
      ..add(DiagnosticsProperty<Matrix4>('canvasMatrix', canvasMatrix))
      ..add(DiagnosticsProperty<double>('scaleX', scaleX))
      ..add(DiagnosticsProperty<double>('scaleY', scaleY))
      ..add(DiagnosticsProperty<double>('translateX', translateX))
      ..add(DiagnosticsProperty<double>('translateY', translateY))
      ..add(DiagnosticsProperty<double>('minScaleX', minScaleX))
      ..add(DiagnosticsProperty<double>('minScaleY', minScaleY))
      ..add(DiagnosticsProperty<double>('maxScaleX', maxScaleX))
      ..add(DiagnosticsProperty<double>('maxScaleY', maxScaleY))
      ..add(DiagnosticsProperty<double>('minTranslateX', minTranslateX))
      ..add(DiagnosticsProperty<double>('minTranslateY', minTranslateY))
      ..add(DiagnosticsProperty<double>('maxTranslateX', maxTranslateX))
      ..add(DiagnosticsProperty<double>('maxTranslateY', maxTranslateY));
  }
}
