part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/31
///
///
/// 手势命中拦截小部件, 将之后的手势全部归为己有处理.
///
/// ```
/// final hitInterceptBox = GestureHitInterceptScope.of(context);
/// hitInterceptBox?.interceptHitBox = this;
/// ```
class GestureHitInterceptScope extends SingleChildRenderObjectWidget {
  /// 获取一个上层的[GestureHitInterceptBox]
  static GestureHitInterceptBox? of(BuildContext context) {
    return context.findAncestorRenderObjectOfType<GestureHitInterceptBox>();
  }

  const GestureHitInterceptScope({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      GestureHitInterceptBox();
}

class GestureHitInterceptBox extends RenderProxyBox {
  /// 是否忽略其他盒子的命中, 前提是设置了[interceptHitBox]
  bool? ignoreOtherBoxHit;

  /// 需要拦截命中的盒子, 如果此box需要拦截事件, 则事件不会传给其他child
  RenderBox? interceptHitBox;

  /// [GestureBinding.hitTestInView] -> [RenderView.hitTest] -> [RenderView.hitTestChildren]
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    return super.hitTestSelf(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var hitBox = interceptHitBox;
    if (hitBox != null) {
      //拦截命中, 并将事件传递给[hitBox]
      //debugger();
      final child = this.child;
      if (child != null &&
          child is GestureHitInterceptBoxTranslucentMixin &&
          child != hitBox) {
        //事件被拦截后, 如果子节点是[GestureHitInterceptBoxTranslucentMixin]类型, 则继续传递命中
        //debugger();
        //super.hitTestChildren(result, position: position);
        if (child.size.contains(position)) {
          if (child.hitTestSelf(position)) {
            result.add(BoxHitTestEntry(child, position));
          }
        }
      }

      final local = hitBox.localToGlobal(Offset.zero, ancestor: this);
      result.addWithPaintOffset(
          offset: local,
          position: position,
          hitTest: (result, transformed) {
            return hitBox.hitTest(result, position: transformed);
          });
      if (ignoreOtherBoxHit ?? true) {
        assert(() {
          l.v('手势命中被拦截:$hitBox position:$position');
          return true;
        }());
        return true;
      }
    }
    return super.hitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    //super.handleEvent(event, entry);
    if (event.isPointerFinish) {
      reset();
    }
  }

  /// 重置
  void reset() {
    interceptHitBox = null;
    ignoreOtherBoxHit = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<bool>('ignoreOtherBoxHit', ignoreOtherBoxHit));
    properties.add(
        DiagnosticsProperty<RenderBox>('interceptHitBox', interceptHitBox));
  }
}

extension GestureHitInterceptScopeEx on Widget {
  ///[GestureHitInterceptScope]
  Widget hitInterceptBox() => GestureHitInterceptScope(child: this);
}

/// 拦截手势命中的盒子
/// [GestureHitInterceptBox]
/// 声明此类的[RenderObject]不会受到拦截盒子的事件拦截
mixin GestureHitInterceptBoxTranslucentMixin {}
