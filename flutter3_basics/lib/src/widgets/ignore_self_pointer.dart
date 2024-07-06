part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/06
///
/// 当点击事件没有命中子组件时, 则忽略点击事件
///
enum IgnorePointerType {
  /// 不忽略
  none,

  /// 忽略所有点击事件
  all,

  /// 只忽略点击在自身上的事件
  self,
}

/// [BuildContext.dispatchNotification]
/// [Notification.dispatch]
class IgnoreSelfPointerNotification extends Notification {
  final IgnorePointerType ignoreType;

  const IgnoreSelfPointerNotification({
    this.ignoreType = IgnorePointerType.self,
  });
}

class IgnoreSelfPointerListener extends StatefulWidget {
  final Widget child;
  final IgnorePointerType? ignoreType;

  const IgnoreSelfPointerListener(
    this.child, {
    super.key,
    this.ignoreType,
  });

  @override
  State<IgnoreSelfPointerListener> createState() =>
      _IgnoreSelfPointerListenerState();
}

class _IgnoreSelfPointerListenerState extends State<IgnoreSelfPointerListener>
    with ValueChangeMixin<IgnoreSelfPointerListener, IgnorePointerType?> {
  @override
  IgnorePointerType? getInitialValueMixin() => widget.ignoreType;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<IgnoreSelfPointerNotification>(
      child: IgnoreSelfPointer(
        ignoreType: currentValueMixin ?? IgnorePointerType.none,
        child: widget.child,
      ),
      onNotification: (notification) {
        currentValueMixin = notification.ignoreType;
        if (isValueChangedMixin) {
          updateState();
          return true;
        }
        return false;
      },
    );
  }
}

/// [IgnorePointer]
class IgnoreSelfPointer extends SingleChildRenderObjectWidget {
  final IgnorePointerType ignoreType;

  const IgnoreSelfPointer({
    super.key,
    this.ignoreType = IgnorePointerType.self,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderIgnoreSelfPointer(ignoreType: ignoreType);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIgnoreSelfPointer renderObject,
  ) {
    renderObject.ignoreType = ignoreType;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('ignoreType', ignoreType));
  }
}

class RenderIgnoreSelfPointer extends RenderProxyBox {
  IgnorePointerType ignoreType;

  RenderIgnoreSelfPointer({
    required this.ignoreType,
    RenderBox? child,
  }) : super(child);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    if (ignoreType == IgnorePointerType.all) {
      return false;
    }
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final hit = super.hitTestChildren(result, position: position);
    if (ignoreType == IgnorePointerType.none) {
      return hit;
    }
    final test = result.path.firstOrNull;
    if (test.runtimeType == HitTestEntry) {
      return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    //debugger();
    if (ignoreType == IgnorePointerType.all ||
        ignoreType == IgnorePointerType.self) {
      return false;
    }
    return true;
  }
}
