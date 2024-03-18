part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/18
///
class TestConstraintsLayout extends SingleChildRenderObjectWidget {
  const TestConstraintsLayout({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => TestConstraintsBox();
}

class TestConstraintsBox extends RenderProxyBox {
  @override
  void performLayout() {
    final constraints = this.constraints;
    final child = this.child;

    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
    } else {
      size = constraints.smallest;
    }

    debugger();
  }
}
