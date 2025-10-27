part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/24
///
/// 参考线构建组件
/// - 在坐标轴上拖动以生成参考线
/// - 在已有的参考线上拖动编辑
///
class RefLineComponent
    with
        IPainterEventHandlerMixin,
        TranslateDetectorMixin,
        KeyEventClientMixin,
        NumberKeyEventDetectorMixin {
  final CanvasAxisManager axisManager;

  /// 要构建什么方向的参考线
  final Axis axis;

  RefLineComponent(this.axisManager, this.axis);

  @override
  double? get translateDetectorSecondSlopX => 1;

  @override
  double? get translateDetectorSecondSlopY => 1;

  /// 吸附控制
  ElementAdsorbControl? _adsorbControl;

  @override
  bool handlePainterPointerEvent(@viewCoordinate PointerEvent event) {
    if (event.isPointerDown) {
      final elementAdsorbControl = axisManager
          .canvasDelegate
          .canvasElementManager
          .canvasElementControlManager
          .elementAdsorbControl;
      if (elementAdsorbControl.isCanvasComponentEnable) {
        elementAdsorbControl.initAdsorbRefValueList(
          ControlTypeEnum.translate,
          includeRefLine: false,
        );
        /*elementAdsorbControl.updateControlElementsBounds(
          axisManager.getRefLineSceneRect(_refLineData),
        );*/
        _adsorbControl = elementAdsorbControl;
      }
    } else if (event.isPointerMove) {
      /*_adsorbControl?.updateControlElementsBounds(
        axisManager.getRefLineSceneRect(_refLineData),
      );*/
    } else if (event.isPointerFinish) {
      _adsorbControl?.dispose(ControlTypeEnum.translate);
      _adsorbControl = null;
    }
    return addTranslateDetectorPointerEvent(event);
  }

  RefLineData? _refLineData;

  @override
  bool handleTranslateDetectorPointerEvent(
    PointerEvent event,
    double ddx,
    double ddy,
    double mdx,
    double mdy,
  ) {
    //debugger();
    if (mdx != 0 && mdy != 0) {
      _refLineData ??= RefLineData(axis, 0);

      final localPosition = event.localPosition;

      //自动吸附查找值
      final adsorbControl = _adsorbControl;
      if (adsorbControl != null) {
        if (axis == Axis.horizontal) {
          @sceneCoordinate
          final refValue = adsorbControl.findYAdsorbRefValue(
            axisManager.toScenePoint(localPosition).y,
            localPosition,
          );
          if (refValue != null) {
            _refLineData?.sceneValue = refValue.refValue;
            axisManager.addRefLine(_refLineData);
            return true;
          }
        } else if (axis == Axis.vertical) {
          final fromX = axisManager.toScenePoint(localPosition).x;
          @sceneCoordinate
          final refValue = adsorbControl.findXAdsorbRefValue(
            fromX,
            localPosition,
          );
          if (refValue != null) {
            _refLineData?.sceneValue = refValue.refValue;
            axisManager.addRefLine(_refLineData);
            return true;
          }
        }
      }

      final scenePoint = axisManager.toScenePoint(localPosition);
      final value = axis == Axis.horizontal ? scenePoint.y : scenePoint.x;
      _refLineData?.sceneValue = value;
      /*l.i(
        "sceneValue->${_refLineData?.axis} $value -> ${_refLineData?.sceneValue}",
      );*/
      axisManager.addRefLine(_refLineData);
    }
    return true;
  }

  @override
  bool handleKeyEvent(KeyEvent event) {
    /*if (event.isKeyDownOrRepeat) {
      l.d("KeyEvent[${event.character}]->$event");
      debugger();
    }*/
    if (event.isEscKey) {
      if (!axisManager.canvasDelegate.canvasEventManager.isPointerDown) {
        axisManager.removeRefLine(_refLineData);
        _refLineData = null;
      }
    }
    return addNumberDetectorKeyEvent(event);
  }

  @override
  bool handleNumberDetectorKeyEvent(KeyEvent event, number) {
    if (_refLineData != null) {
      final dp = (number as double).toDpFromUnit(axisManager.axisUnit);
      _refLineData?.sceneValue = dp;
      axisManager.addRefLine(_refLineData);
    }
    return true;
  }
}

/// 参考线数据
final class RefLineData {
  /// 轴向
  ///
  /// - [Axis.horizontal] 横向参考线, 横着绘制
  /// - [Axis.vertical] 纵向参考线, 竖着绘制
  final Axis axis;

  /// 场景中, 距离场景原点的距离值
  @dp
  @sceneCoordinate
  double sceneValue;

  RefLineData(this.axis, this.sceneValue);
}
