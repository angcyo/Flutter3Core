part of flutter3_widgets;

/// https://github.com/flutterchina/flukit
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/05
///

typedef AfterLayoutCallback = void Function(
    BuildContext parentContext, RenderObject? childRenderObject);

/// 在小部件布局完成之后第一时间触发回调
class AfterLayout extends SingleChildRenderObjectWidget {

  /// child布局之后的回调
  /// 在此回调中不能直接调用setState(), 否则会导致循环调用
  /// This might be because setState() was called from a layout or paint callback.
  /// If a change is needed to the widget tree, it should be applied as the tree is being built.
  /// Scheduling a change for the subsequent frame instead results in an interface that lags behind by one frame.
  /// If this was done to make your build dependent on a size measured at layout time, consider using a LayoutBuilder,
  /// CustomSingleChildLayout, or CustomMultiChildLayout.
  /// If, on the other hand, the one frame delay is the desired effect,
  /// for example because this is an animation,
  /// consider scheduling the frame in a post-frame callback using SchedulerBinding.addPostFrameCallback or using an AnimationController to trigger the animation.
  final AfterLayoutCallback callback;

  const AfterLayout({super.key, super.child, required this.callback});

  @override
  AfterLayoutRenderObject createRenderObject(BuildContext context) =>
      AfterLayoutRenderObject(callback, context);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant AfterLayoutRenderObject renderObject,
  ) {
    renderObject.callback = callback;
    renderObject.context = context;
  }
}

class AfterLayoutRenderObject extends RenderProxyBox {
  late AfterLayoutCallback callback;
  late BuildContext context;

  AfterLayoutRenderObject(this.callback, this.context);

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(constraints, parentUsesSize: parentUsesSize);
    callback(context, child);
  }

  @override
  void performLayout() {
    super.performLayout();
    /*WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      callback(context);
    });*/
  }
}
