part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/25
///
/// 在[CustomScrollView]中撑满整个布局的小部件
/// 类似[Expanded]效果
/// 通过获取到[SliverConstraints]实现
class SliverExpandWidget extends SingleChildRenderObjectWidget
    with NotSliverTile {
  /// child在self中的对齐方式
  final AlignmentDirectional alignment;

  const SliverExpandWidget({
    super.key,
    super.child,
    this.alignment = AlignmentDirectional.center,
  });

  @override
  SliverExpandBox createRenderObject(BuildContext context) =>
      SliverExpandBox(alignment: alignment);

  @override
  void updateRenderObject(BuildContext context, SliverExpandBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..alignment = alignment
      ..markNeedsLayout();
  }
}

/// [RenderProxyBox]
/// [RenderShiftedBox]
/// [RenderAligningShiftedBox]
class SliverExpandBox extends RenderShiftedBox {
  AlignmentDirectional alignment;

  SliverExpandBox({
    this.alignment = AlignmentDirectional.center,
  }) : super(null);

  @override
  void performLayout() {
    //获取到约束
    final constraints = this.constraints;
    final constraintSize = constraints.biggest;
    final parentConstraints = parent?.constraints;

    double width = constraintSize.width;
    double height = constraintSize.height;
    //debugger();
    if (width == double.infinity) {
      if (parentConstraints is BoxConstraints) {
        width = parentConstraints.maxWidth;
      } else if (parentConstraints is SliverConstraints) {
        width = parentConstraints.crossAxisExtent;
      }
    }
    if (height == double.infinity) {
      if (parentConstraints is BoxConstraints) {
        height = parentConstraints.maxHeight;
      } else if (parentConstraints is SliverConstraints) {
        height = parentConstraints.viewportMainAxisExtent;
      }
    }
    // debugger();
    size = Size(width, height);

    //child
    if (child != null) {
      //debugger();
      //child!.layout(constraints, parentUsesSize: true);
      child!.layout(BoxConstraints.loose(size), parentUsesSize: true);
      alignChildOffset(alignment, size, null, child: child);
    }

    /*final sliverConstraints = findSliverConstraints();
    if (sliverConstraints == null) {
      super.performLayout();
    } else {
      Size expandSize;
      if (sliverConstraints.axis == Axis.vertical) {
        //垂直滚动列表
        expandSize = Size(sliverConstraints.crossAxisExtent,
            sliverConstraints.remainingPaintExtent);
      } else {
        //水平滚动列表
        expandSize = Size(sliverConstraints.remainingPaintExtent,
            sliverConstraints.crossAxisExtent);
      }

      if (child != null) {
        final maxWidth =
            expandSize.width <= 0 ? double.infinity : expandSize.width;
        final maxHeight =
            expandSize.height <= 0 ? double.infinity : expandSize.height;

        debugger();
        child!.layout(constraints, parentUsesSize: true);

        */ /*child!.layout(BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            parentUsesSize: true);
        final size = Size(max(expandSize.width, child!.size.width),
            max(expandSize.height, child!.size.height));
        debugger();
        expandSize = size;*/ /*
        alignChildOffset(alignment, expandSize, null, child: child);
      }
      //size = expandSize;
      size = constraints.biggest;
    }*/
  }

/*@override
  void paint(PaintingContext context, ui.Offset offset) {
    assert(() {
      context.canvas.drawRect(
        offset & size,
        Paint()..color = Colors.purpleAccent,
      );
      return true;
    }());
    super.paint(context, offset);
  }*/
}

extension SliverExpandWidgetEx on Widget {
  /// [SliverExpandWidget]扩展方法
  Widget sliverExpand() {
    return SliverExpandWidget(child: this);
  }
}
