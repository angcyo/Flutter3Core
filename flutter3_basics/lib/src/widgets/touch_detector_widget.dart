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

  const TouchDetectorWidget({
    super.key,
    super.child,
    this.onClick,
    this.onLongPress,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderTouchDetector(
        onClick: onClick,
        onLongPress: onLongPress,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderTouchDetector renderObject) {
    renderObject
      ..onClick = onClick
      ..onLongPress = onLongPress;
  }
}

class RenderTouchDetector extends RenderProxyBox with TouchDetectorMixin {
  PointerAction? onClick;
  PointerAction? onLongPress;

  /// 是否启用事件检测
  bool get _enableTouchDetector => onClick != null || onLongPress != null;

  RenderTouchDetector({
    RenderBox? child,
    this.onClick,
    this.onLongPress,
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
  }

  @override
  bool onTouchDetectorPointerEvent(
      PointerEvent event, TouchDetectorType touchType) {
    //debugger();
    if (touchType == TouchDetectorType.click) {
      onClick?.call(event);
    } else if (touchType == TouchDetectorType.longPress) {
      onLongPress?.call(event);
    }
    return super.onTouchDetectorPointerEvent(event, touchType);
  }
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
  }) {
    if (!enableClick && !enableLongPress) {
      return this;
    }
    if (enableClick && onClick == null) {
      if (onTap != null) {
        onClick = (event) {
          onTap.call();
        };
      }
    }
    return TouchDetectorWidget(
      onClick: enableClick ? onClick : null,
      onLongPress: enableLongPress ? onLongPress : null,
      child: this,
    );
  }
}
