part of '../../../flutter3_widgets.dart';

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
  /// [child]在[self]中的对齐方式
  final AlignmentDirectional alignment;

  /// 需要排除的宽高
  final double excludeWidth;
  final double excludeHeight;

  const SliverExpandWidget({
    super.key,
    super.child,
    this.alignment = AlignmentDirectional.center,
    this.excludeWidth = 0,
    this.excludeHeight = 0,
  });

  @override
  SliverExpandBox createRenderObject(BuildContext context) => SliverExpandBox(
    alignment: alignment,
    excludeWidth: excludeWidth,
    excludeHeight: excludeHeight,
  );

  @override
  void updateRenderObject(BuildContext context, SliverExpandBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..alignment = alignment
      ..excludeWidth = excludeWidth
      ..excludeHeight = excludeHeight
      ..markNeedsLayout();
  }
}

/// [RenderProxyBox]
/// [RenderShiftedBox]
/// [RenderAligningShiftedBox]
class SliverExpandBox extends RenderShiftedBox {
  AlignmentDirectional alignment;

  /// 需要排除的宽高
  double excludeWidth;
  double excludeHeight;

  SliverExpandBox({
    this.alignment = AlignmentDirectional.center,
    this.excludeWidth = 0,
    this.excludeHeight = 0,
  }) : super(null);

  /// 获取父节点有效的最大宽度约束
  double? getParentBoxMaxWidth([RenderObject? parent, int depth = 0]) {
    if (parent == null || depth > 10) {
      return null;
    }
    final constraints = parent.constraints;
    if (constraints is BoxConstraints && constraints.maxWidth.isValid) {
      return constraints.maxWidth;
    }
    return getParentBoxMaxWidth(parent.parent, depth + 1);
  }

  /// 获取父节点有效的最大高度约束
  double? getParentBoxMaxHeight([RenderObject? parent, int depth = 0]) {
    if (parent == null || depth > 10) {
      return null;
    }
    final constraints = parent.constraints;
    if (constraints is BoxConstraints && constraints.maxHeight.isValid) {
      return constraints.maxHeight;
    }
    return getParentBoxMaxHeight(parent.parent, depth + 1);
  }

  @override
  void performLayout() {
    //获取到约束
    final constraints = this.constraints;
    final constraintSize = constraints.biggest;
    final parentConstraints = parent?.constraints;
    final parentMaxWidth = getParentBoxMaxWidth(parent, 0);
    final parentMaxHeight = getParentBoxMaxHeight(parent, 0);

    double width = constraintSize.width;
    double height = constraintSize.height;
    //debugger();
    if (width == double.infinity) {
      if (parentMaxWidth != null) {
        width = parentMaxWidth.ensureValid(parentMaxHeight!);
      } else if (parentConstraints is SliverConstraints) {
        width = parentConstraints.crossAxisExtent;
      }
    }
    if (height == double.infinity) {
      if (parentMaxHeight != null) {
        height = parentMaxHeight.ensureValid(parentMaxWidth!);
      } else if (parentConstraints is SliverConstraints) {
        height = parentConstraints.viewportMainAxisExtent;
      }
    }
    //debugger();
    size = Size(width - excludeWidth, height - excludeHeight);

    //child
    if (child != null) {
      //debugger();
      //child!.layout(constraints, parentUsesSize: true);
      child!.layout(BoxConstraints.loose(size), parentUsesSize: true);
      alignChildOffset(alignment, size, child: child);
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

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    /*assert(() {
      context.canvas.drawRect(
        offset & size,
        Paint()
          ..color = Colors.purpleAccent
          ..style = PaintingStyle.stroke,
      );
      return true;
    }());*/
  }
}

extension SliverExpandWidgetEx on Widget {
  /// [SliverExpandWidget]扩展方法
  Widget sliverExpand({
    AlignmentDirectional alignment = AlignmentDirectional.center,
    double excludeWidth = 0,
    double excludeHeight = 0,
    bool enable = true,
  }) {
    if (!enable) {
      return this;
    }
    return SliverExpandWidget(
      alignment: alignment,
      excludeWidth: excludeWidth,
      excludeHeight: excludeHeight,
      child: this,
    );
  }
}
