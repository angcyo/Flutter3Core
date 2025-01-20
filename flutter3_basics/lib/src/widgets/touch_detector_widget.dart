part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/14
///
/// 手势点击以及长按事件处理小部件
/// 会比[GestureDetector].[onTap]回调快
/// [RawGestureDetector]
class TouchDetectorWidget extends SingleChildRenderObjectWidget {
  final PointerAction? onClick;
  final PointerAction? onLongPress;

  /// 手势事件, 未处理
  final PointerAction? onPointerEvent;

  /// 是否激活长按循环事件通知
  final bool enableLoopLongPress;

  const TouchDetectorWidget({
    super.key,
    super.child,
    this.onClick,
    this.onLongPress,
    this.onPointerEvent,
    this.enableLoopLongPress = false,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderTouchDetector(
        onClick: onClick,
        onLongPress: onLongPress,
        onPointerEvent: onPointerEvent,
        enableLoopLongPress: enableLoopLongPress,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderTouchDetector renderObject) {
    renderObject
      ..onClick = onClick
      ..onPointerEvent = onPointerEvent
      ..enableLoopLongPress = enableLoopLongPress
      ..onLongPress = onLongPress;
  }
}

/// [RenderMouseRegion] 鼠标区域, 用来自定义鼠标样式
class RenderTouchDetector extends RenderProxyBox
    with TouchDetectorMixin
    implements MouseTrackerAnnotation {
  PointerAction? onClick;
  PointerAction? onLongPress;

  /// 手势事件, 未处理
  PointerAction? onPointerEvent;

  @override
  bool enableLoopLongPress = false;

  /// 是否启用事件检测
  bool get _enableTouchDetector => onClick != null || onLongPress != null;

  RenderTouchDetector({
    RenderBox? child,
    this.onClick,
    this.onLongPress,
    this.onPointerEvent,
    this.enableLoopLongPress = false,
  }) : super(child);

  @override
  bool hitTest(BoxHitTestResult result, {required ui.Offset position}) {
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return _enableTouchDetector;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    //debugger();
    checkLongPress = onLongPress != null;
    if (_enableTouchDetector) {
      addTouchDetectorPointerEvent(event);
    }
    onPointerEvent?.call(event);
  }

  @override
  bool onTouchDetectorPointerEvent(
    PointerEvent event,
    TouchDetectorType touchType,
  ) {
    //debugger();
    if (touchType == TouchDetectorType.click) {
      onClick?.call(event);
    } else if (touchType == TouchDetectorType.longPress) {
      onLongPress?.call(event);
    }
    return super.onTouchDetectorPointerEvent(event, touchType);
  }

  //region --Mouse--

  @override
  MouseCursor get cursor =>
      _enableTouchDetector ? SystemMouseCursors.click : MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => null;

  @override
  PointerExitEventListener? get onExit => null;

  @override
  bool get validForMouseTracker => false;

//endregion --Mouse--
}

extension TouchDetectorWidgetEx on Widget {
  /// 点击/长按事件识别
  /// [TouchDetectorWidget]扩展方法
  Widget onTouchDetector({
    GestureTapCallback? onTap,
    PointerAction? onClick,
    PointerAction? onLongPress,
    bool enableClick = true,
    bool enableLongPress = false,
    bool enableLoopLongPress = false,
  }) {
    //debugger(when: !enableClick);
    if (!enableClick && !enableLongPress) {
      if (isDesktopOrWeb || mouseIsConnected) {
        return mouse(cursor: SystemMouseCursors.forbidden);
      }
      return this;
    }
    if (enableClick && onClick == null) {
      if (onTap != null) {
        onClick = (event) {
          onTap.call();
        };
      }
    }
    final clickAction = enableClick ? onClick : null;
    final longPressAction = enableLongPress ? onLongPress : null;
    if (clickAction == null && longPressAction == null) {
      if (mouseIsConnected) {
        return mouse(cursor: SystemMouseCursors.forbidden);
      }
      return this;
    }
    return TouchDetectorWidget(
      onClick: clickAction,
      onLongPress: longPressAction,
      enableLoopLongPress: enableLoopLongPress,
      child: this,
    );
  }
}
