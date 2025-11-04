part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/20
///
/// 智能吸附控制
///
/// - [initAdsorbRefValueList] 初始化吸附目标数据
/// - [findElementXAdsorbRefValue] 查找吸附参考数据
/// - [findElementYAdsorbRefValue]
/// - [findXAdsorbRefValue]
/// - [findYAdsorbRefValue]
///
/// - [CanvasElementControlManager] in
/// - [CanvasElementControlManager.elementAdsorbControl] in
///
class ElementAdsorbControl
    with CanvasComponentMixin, CanvasElementControlManagerMixin {
  /// 画布元素控制器
  @override
  final CanvasElementControlManager canvasElementControlManager;

  @override
  bool get isCanvasComponentEnable => canvasElementControlManager
      .canvasDelegate
      .canvasStyle
      .enableElementAdsorb;

  /// 是否临时关闭吸附
  bool get isIgnoreAdsorb =>
      isKeyPressed(key: canvasStyle.ignoreAdsorbKeyboardKey);

  @override
  set isCanvasComponentEnable(bool componentEnable) {
    canvasElementControlManager.canvasDelegate.canvasStyle.enableElementAdsorb =
        componentEnable;
  }

  ElementAdsorbControl(this.canvasElementControlManager);

  //region --core--

  /// 绘制吸附线和距离信息
  /// [CanvasElementControlManager.paint]驱动, 无法绘制在坐标轴上
  /// [CanvasElementManager.paintElements]驱动, 可以绘制在坐标轴上
  @entryPoint
  void paintAdsorb(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    if (isIgnoreAdsorb) {
      return;
    }
    final controlElementBounds =
        canvasElementControlManager
            ._currentControlElementRef
            ?.target
            ?.elementsBounds ??
        _controlElementsBounds;
    if (controlElementBounds == null) {
      return;
    }
    paintMeta.withPaintMatrix(canvas, () {
      _paintXAdsorb(canvas, paintMeta, controlElementBounds);
      _paintYAdsorb(canvas, paintMeta, controlElementBounds);
    });
  }

  /// 绘制x轴的吸附线, 竖线
  void _paintXAdsorb(
    Canvas canvas,
    PaintMeta paintMeta,
    Rect controlElementBounds,
  ) {
    final xRefValue = _xAdsorbRefValue;
    final refBounds = xRefValue?.refBounds;
    if (xRefValue != null) {
      final x = xRefValue.refValue;

      //上下坐标
      double top, bottom;
      if (refBounds != null) {
        if (refBounds.center.dy > controlElementBounds.center.dy) {
          //参考元素在目标的下面
          top = controlElementBounds.bottom;
          bottom = refBounds.top;
        } else {
          //参考元素在目标的上面
          top = refBounds.bottom;
          bottom = controlElementBounds.top;
        }
      } else {
        top = controlElementBounds.top - controlElementBounds.height / 2;
        bottom = controlElementBounds.bottom + controlElementBounds.height / 2;
      }

      //距离
      @dp
      @sceneCoordinate
      double c = bottom - top;

      if (refBounds != null) {
        if (xRefValue.refType == RefValueType.center || c < 0) {
          top = refBounds.center.dy;
          bottom = controlElementBounds.center.dy;
          c = (bottom - top).abs();
        }
      }

      //绘制吸附线
      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        Paint()
          ..color = canvasStyle.adsorbLineColor
          ..strokeWidth = 1 / paintMeta.canvasScale,
      );

      //绘制距离
      if (refBounds != null) {
        canvas.drawText(
          axisUnit.format(c.toUnitFromDp(axisUnit)),
          textColor: canvasStyle.adsorbTextColor,
          fontSize: canvasStyle.adsorbTextSize / paintMeta.canvasScale,
          getOffset: (painter) {
            return Offset(
              x + canvasStyle.adsorbTextOffset,
              (top + bottom) / 2 - painter.size.height / 2,
            );
          },
        );
      }
    }
  }

  /// 绘制y轴的吸附线, 横线
  void _paintYAdsorb(
    Canvas canvas,
    PaintMeta paintMeta,
    Rect controlElementBounds,
  ) {
    final yRefValue = _yAdsorbRefValue;
    final refBounds = yRefValue?.refBounds;
    if (yRefValue != null) {
      final y = yRefValue.refValue;

      //左右坐标
      double left, right;
      if (refBounds != null) {
        if (refBounds.center.dx > controlElementBounds.center.dx) {
          //参考元素在目标的右边
          left = controlElementBounds.right;
          right = refBounds.left;
        } else {
          //参考元素在目标的左边
          left = refBounds.right;
          right = controlElementBounds.left;
        }
      } else {
        left = controlElementBounds.left - controlElementBounds.width / 2;
        right = controlElementBounds.right + controlElementBounds.width / 2;
      }

      //距离
      @dp
      @sceneCoordinate
      double c = right - left;

      if (refBounds != null) {
        if (yRefValue.refType == RefValueType.center || c < 0) {
          left = refBounds.center.dx;
          right = controlElementBounds.center.dx;
          c = (right - left).abs();
        }
      }

      //绘制吸附线
      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = canvasStyle.adsorbLineColor
          ..strokeWidth = 1 / paintMeta.canvasScale,
      );

      //绘制距离
      if (refBounds != null) {
        canvas.drawText(
          axisUnit.format(c.toUnitFromDp(axisUnit)),
          textColor: canvasStyle.adsorbTextColor,
          fontSize: canvasStyle.adsorbTextSize / paintMeta.canvasScale,
          getOffset: (painter) {
            return Offset(
              (left + right) / 2 - painter.size.width / 2,
              y - canvasStyle.adsorbTextOffset - painter.size.height,
            );
          },
        );
      }
    }
  }

  /// 初始化吸附参数/参考值信息
  /// [CanvasElementControlManager.onHandleControlStateChanged] 驱动
  @callPoint
  void initAdsorbRefValueList(
    ControlTypeEnum controlType, {
    ElementPainter? controlElement,
    @dp @sceneCoordinate Rect? controlBounds,
    //--
    bool includeElement = true,
    bool includeCanvasContent = true,
    bool includeAxis = true,
    bool includeRefLine = true,
  }) {
    if (controlType == ControlTypeEnum.translate) {
      //仅在平移时支持吸附
      _initTranslateRefValue(
        controlElement: controlElement,
        controlBounds: controlBounds,
        //--
        includeElement: includeElement,
        includeCanvasContent: includeCanvasContent,
        includeAxis: includeAxis,
        includeRefLine: includeRefLine,
      );
      //debugger();
    } else {
      assert(() {
        l.d("不支持吸附的控制行为[$controlType]");
        return true;
      }());
    }
  }

  /// 释放资源
  /// [CanvasElementControlManager.onHandleControlStateChanged] 驱动
  @callPoint
  void dispose(ControlTypeEnum controlType) {
    //debugger();
    _xAdsorbRefValue = null;
    _yAdsorbRefValue = null;
    _xRefValueList.clear();
    _yRefValueList.clear();
  }

  /// 查找元素x轴上的吸附参考值
  /// [element] 操作的元素
  /// [localPosition] 当前手势的位置
  /// [tx] 原本需要平移的x量
  /// [mx] 当前手指移动的距离
  /// [findXAdsorbRefValue]
  AdsorbRefValue? findElementXAdsorbRefValue(
    ElementPainter? element,
    @dp @viewCoordinate Offset localPosition,
    @dp @sceneCoordinate double tx,
    @dp @viewCoordinate double mx,
  ) {
    final controlElementsBounds = _controlElementsBounds;
    if (element == null || controlElementsBounds == null) {
      return null;
    }
    if (isAdsorbXPosition(localPosition)) {
      assert(() {
        //l.v('吸附x轴->$_xAdsorbRefValue');
        return true;
      }());
      return _xAdsorbRefValue;
    }

    //先使用left为参照值查找
    AdsorbRefValue? refValue = findXAdsorbRefValue(
      controlElementsBounds.left + tx,
      localPosition,
    );
    if (refValue == null) {
      //再使用center为参考值查找
      refValue = findXAdsorbRefValue(
        controlElementsBounds.center.dx + tx,
        localPosition,
      );
      if (refValue == null) {
        //最后使用right为参考值查找
        refValue = findXAdsorbRefValue(
          controlElementsBounds.right + tx,
          localPosition,
        );
        if (refValue == null) {
          //没有找到可以吸附的值
        } else {
          refValue.adsorbValue =
              refValue.refValue - controlElementsBounds.right;
        }
      } else {
        refValue.adsorbValue =
            refValue.refValue - controlElementsBounds.center.dx;
      }
    } else {
      refValue.adsorbValue = refValue.refValue - controlElementsBounds.left;
    }
    return refValue;
  }

  /// 查找元素y轴上的吸附参考值
  /// [element] 操作的元素
  /// [localPosition] 当前手势的位置
  /// [ty] 原本需要平移的y量
  /// [my] 当前手指移动的距离
  /// [findXAdsorbRefValue]
  AdsorbRefValue? findElementYAdsorbRefValue(
    ElementPainter? element,
    @dp @viewCoordinate Offset localPosition,
    @dp @sceneCoordinate double ty,
    @dp @viewCoordinate double my,
  ) {
    final controlElementsBounds = _controlElementsBounds;
    if (element == null || controlElementsBounds == null) {
      return null;
    }
    if (isAdsorbYPosition(localPosition)) {
      assert(() {
        //l.v('吸附y轴->$_yAdsorbRefValue');
        return true;
      }());
      return _yAdsorbRefValue;
    }

    //先使用top为参照值查找
    AdsorbRefValue? refValue = findYAdsorbRefValue(
      controlElementsBounds.top + ty,
      localPosition,
    );
    if (refValue == null) {
      //再使用center为参考值查找
      refValue = findYAdsorbRefValue(
        controlElementsBounds.center.dy + ty,
        localPosition,
      );
      if (refValue == null) {
        //最后使用bottom为参考值查找
        refValue = findYAdsorbRefValue(
          controlElementsBounds.bottom + ty,
          localPosition,
        );
        if (refValue == null) {
          //没有找到可以吸附的值
        } else {
          refValue.adsorbValue =
              refValue.refValue - controlElementsBounds.bottom;
        }
      } else {
        refValue.adsorbValue =
            refValue.refValue - controlElementsBounds.center.dy;
      }
    } else {
      refValue.adsorbValue = refValue.refValue - controlElementsBounds.top;
    }
    return refValue;
  }

  /// 是否需要吸附x轴的位置
  bool isAdsorbXPosition(@dp @viewCoordinate Offset localPosition) {
    final adsorbLocalPosition = _xAdsorbRefValue?.localPosition;
    if (adsorbLocalPosition != null) {
      //吸附
      final dx = (adsorbLocalPosition - localPosition).dx;
      return dx.abs() < canvasStyle.adsorbEscapeThreshold;
    }
    return false;
  }

  /// 是否需要吸附y轴的位置
  bool isAdsorbYPosition(@dp @viewCoordinate Offset localPosition) {
    final adsorbLocalPosition = _yAdsorbRefValue?.localPosition;
    if (adsorbLocalPosition != null) {
      //吸附
      final dy = (adsorbLocalPosition - localPosition).dy;
      return dy.abs() < canvasStyle.adsorbEscapeThreshold;
    }
    return false;
  }

  /// 查找x轴的吸附参考值
  /// [x] 当前在场景中的x值
  /// [localPosition] 当前手势的位置
  AdsorbRefValue? findXAdsorbRefValue(
    @dp @sceneCoordinate double x,
    @dp @viewCoordinate Offset localPosition,
  ) {
    final xRefValue = _findMinRefValue(
      _xRefValueList,
      x,
      minThreshold: canvasStyle.adsorbThreshold,
      includeEqual: true,
      includeLess: true,
      includeGreater: true,
    );
    //l.v("吸附->$xRefValue");
    final lastRefValue = _xAdsorbRefValue?.refValue;
    _xAdsorbRefValue = xRefValue;
    _xAdsorbRefValue?.localPosition = localPosition;
    if (xRefValue != null) {
      //震动
      assert(() {
        //l.v('找到x轴的吸附参考值->$xRefValue');
        return true;
      }());
      if (lastRefValue == null && lastRefValue != xRefValue.refValue) {
        canvasDelegate.vibrate();
      }
    }
    return xRefValue;
  }

  /// 查找y轴的吸附参考值
  /// [y] 当前在场景中的y值
  /// [localPosition] 当前手势的位置
  AdsorbRefValue? findYAdsorbRefValue(
    @dp @sceneCoordinate double y,
    @dp @viewCoordinate Offset localPosition,
  ) {
    final yRefValue = _findMinRefValue(
      _yRefValueList,
      y,
      minThreshold: canvasStyle.adsorbThreshold,
      includeEqual: true,
      includeLess: true,
      includeGreater: true,
    );
    //l.v("吸附->$yRefValue");
    final lastRefValue = _yAdsorbRefValue?.refValue;
    _yAdsorbRefValue = yRefValue;
    _yAdsorbRefValue?.localPosition = localPosition;
    if (yRefValue != null) {
      //震动
      assert(() {
        //l.v('找到x轴的吸附参考值->$yRefValue');
        return true;
      }());
      if (lastRefValue == null && lastRefValue != yRefValue.refValue) {
        canvasDelegate.vibrate();
      }
    }
    return yRefValue;
  }

  //endregion --core--

  //region --辅助--

  /// 上一次x轴的吸附值
  AdsorbRefValue? _xAdsorbRefValue;

  /// 上一次y轴的吸附值
  AdsorbRefValue? _yAdsorbRefValue;

  /// x轴需要查找的参考值集合
  final List<AdsorbRefValue> _xRefValueList = [];

  /// y轴需要查找的参考值集合
  final List<AdsorbRefValue> _yRefValueList = [];

  /// 开始控制时元素边界
  @dp
  @sceneCoordinate
  Rect? _controlElementsBounds;

  /// 初始化移动时的参考值
  /// - [controlElement] 正在被控制的元素
  /// - [controlBounds] 或者被控制的边界
  ///
  /// - [includeElement] 是否需要元素边界的吸附?
  /// - [includeCanvasContent] 是否需要画布内容边界的吸附?
  /// - [includeAxis] 是否需要坐标系刻度的吸附?
  /// - [includeRefLine] 是否需要参考线的吸附?
  ///
  void _initTranslateRefValue({
    ElementPainter? controlElement,
    @dp @sceneCoordinate Rect? controlBounds,
    //--
    bool includeElement = true,
    bool includeCanvasContent = true,
    bool includeAxis = true,
    bool includeRefLine = true,
  }) {
    _xRefValueList.clear();
    _yRefValueList.clear();

    // 要排除的元素
    final exclude = [
      if (controlElement is ElementSelectComponent) ...?controlElement.children,
      if (controlElement is! ElementSelectComponent) controlElement,
    ];

    final elementsBounds = controlElement?.elementsBounds ?? controlBounds;
    _controlElementsBounds = elementsBounds;

    //吸附的矩形信息
    void adsorbRect(Rect bounds, {ElementPainter? element}) {
      _xRefValueList.add(
        AdsorbRefValue(
          refType: RefValueType.left,
          refValue: bounds.left,
          refElement: element,
          refBounds: bounds,
        ),
      );
      _xRefValueList.add(
        AdsorbRefValue(
          refType: RefValueType.center,
          refValue: bounds.center.dx,
          refElement: element,
          refBounds: bounds,
        ),
      );
      _xRefValueList.add(
        AdsorbRefValue(
          refType: RefValueType.right,
          refValue: bounds.right,
          refElement: element,
          refBounds: bounds,
        ),
      );
      //--
      _yRefValueList.add(
        AdsorbRefValue(
          refType: RefValueType.top,
          refValue: bounds.top,
          refElement: element,
          refBounds: bounds,
        ),
      );
      _yRefValueList.add(
        AdsorbRefValue(
          refType: RefValueType.center,
          refValue: bounds.center.dy,
          refElement: element,
          refBounds: bounds,
        ),
      );
      _yRefValueList.add(
        AdsorbRefValue(
          refType: RefValueType.bottom,
          refValue: bounds.bottom,
          refElement: element,
          refBounds: bounds,
        ),
      );
    }

    //计算需要吸附的元素
    if (includeElement) {
      for (final element in canvasElementManager.elements) {
        if (!element.isVisible /*元素不可见*/ ||
            exclude.contains(element) /*需要排除元素*/ ||
            !element.isVisibleInCanvasBox(canvasViewBox) /*元素不在画布内*/ ) {
          continue;
        }
        element.elementsBounds?.let((it) {
          adsorbRect(it, element: element);
        });
      }
    }
    //--
    if (includeCanvasContent) {
      canvasDelegate
          .canvasPaintManager
          .contentManager
          .canvasContentFollowRectInner
          ?.let((it) {
            adsorbRect(it);
          });
    }
    //计算需要吸附的坐标系信息
    final axisManager = canvasDelegate.canvasPaintManager.axisManager;
    if (includeAxis) {
      for (final data in axisManager.xAxisData) {
        if (data.axisType.have(IUnit.axisTypePrimary)) {
          _xRefValueList.add(
            AdsorbRefValue(
              refType: RefValueType.left,
              refValue: data.sceneValue,
              refElement: null,
              refBounds: null,
            ),
          );
        }
      }
      for (final data in axisManager.yAxisData) {
        if (data.axisType.have(IUnit.axisTypePrimary)) {
          _yRefValueList.add(
            AdsorbRefValue(
              refType: RefValueType.top,
              refValue: data.sceneValue,
              refElement: null,
              refBounds: null,
            ),
          );
        }
      }
    }
    //--
    if (includeRefLine) {
      for (final data in axisManager.refLineDataList) {
        if (data.axis == Axis.horizontal) {
          _yRefValueList.add(
            AdsorbRefValue(
              refType: RefValueType.center,
              refValue: data.sceneValue,
              refElement: null,
              refBounds: null,
            ),
          );
        } else if (data.axis == Axis.vertical) {
          _xRefValueList.add(
            AdsorbRefValue(
              refType: RefValueType.center,
              refValue: data.sceneValue,
              refElement: null,
              refBounds: null,
            ),
          );
        }
      }
    }
  }

  /// 仅更新控制元素的边界
  /// - 比如在参考线的拖动中, [bounds]就是参考线的是是位置
  void updateControlElementsBounds(@dp @sceneCoordinate Rect? bounds) {
    _controlElementsBounds = bounds;
  }

  /// 在[list]中, 查找于[value]距离最小的[AdsorbRefValue]值
  /// [minThreshold] 找到的差值需要<=此值, 否则返回null
  /// [includeEqual]是否包含等于[value]的参考值值
  /// [includeLess]是否包含小于[value]的参考值值
  /// [includeGreater]是否包含大于[value]的参考值值
  AdsorbRefValue? _findMinRefValue(
    List<AdsorbRefValue> list,
    double value, {
    double? minThreshold,
    bool includeEqual = true,
    bool includeLess = true,
    bool includeGreater = true,
  }) {
    if (list.isEmpty) {
      return null;
    }
    AdsorbRefValue? minRefValue;
    double minDistance = 0;
    for (final refValue in list) {
      if (refValue.refValue == value) {
        if (!includeEqual) {
          continue;
        }
      } else if (refValue.refValue > value) {
        if (!includeGreater) {
          continue;
        }
      } else if (refValue.refValue < value) {
        if (!includeLess) {
          continue;
        }
      }
      final distance = (refValue.refValue - value).abs();
      if (minRefValue == null || distance < minDistance) {
        minRefValue = refValue;
        minDistance = distance;
      }
    }
    if (minThreshold != null) {
      if (minDistance > minThreshold) {
        return null;
      }
    }
    return minRefValue;
  }

  //endregion --辅助--
}

/// 引用值的类型, 表示对齐目标的什么位置
enum RefValueType { none, left, top, center, right, bottom }

/// 吸附参考值结构
class AdsorbRefValue {
  /// 引用值的类型
  @implementation
  final RefValueType refType;

  /// 场景中的参考值, 这个值通常也是用来吸附的值
  @dp
  @sceneCoordinate
  final double refValue;

  /// 参考的元素, 如果有
  @implementation
  final ElementPainter? refElement;

  /// 参考的边界, 如果有. 用来计算到边界的距离.
  @dp
  @sceneCoordinate
  final Rect? refBounds;

  /// 吸附之后, 元素需要平移的差值, left到目标位置的值
  /// 参考值与控制元素的距离, 可以直接使用
  /// 这个值在平移时, 永远都是相对于left/top为锚点的差值
  @dp
  @output
  @sceneCoordinate
  double? adsorbValue;

  /// 吸附之后, 记录的手势位置, 用来逃离吸附
  @dp
  @output
  @viewCoordinate
  Offset? localPosition;

  AdsorbRefValue({
    required this.refType,
    required this.refValue,
    this.refElement,
    this.refBounds,
  });

  @override
  String toString() =>
      'AdsorbRefValue(refType: $refType, refValue: $refValue, refBounds: $refBounds, adsorbValue: $adsorbValue, refElement: $refElement)';
}
