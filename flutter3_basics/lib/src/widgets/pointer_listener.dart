part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/12/27
///
/// 回调
typedef PointerEventListener = void Function(PointerEvent event);

/// 用来回调[PointerEvent]事件
/// [Listener]
class PointerListenerWidget extends SingleChildRenderObjectWidget {
  const PointerListenerWidget({
    super.key,
    super.child,
    this.onPointer,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final PointerEventListener? onPointer;
  final HitTestBehavior behavior;

  @override
  PointerListener createRenderObject(BuildContext context) {
    return PointerListener(onPointer: onPointer, behavior: behavior);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant PointerListener renderObject,
  ) {
    renderObject
      ..onPointer = onPointer
      ..behavior = behavior;
  }
}

/// [RenderPointerListener]
class PointerListener extends RenderProxyBoxWithHitTestBehavior {
  PointerEventListener? onPointer;

  PointerListener({super.behavior, super.child, this.onPointer});

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    onPointer?.call(event);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagsSummary<Function?>('listeners', <String, Function?>{
        'pointer': onPointer,
      }, ifEmpty: '<none>'),
    );
  }
}
