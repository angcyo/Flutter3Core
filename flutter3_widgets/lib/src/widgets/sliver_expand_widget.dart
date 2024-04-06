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
  _SliverExpandBox createRenderObject(BuildContext context) => _SliverExpandBox(
        alignment: alignment,
      );

  @override
  void updateRenderObject(BuildContext context, _SliverExpandBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..alignment = alignment
      ..markNeedsLayout();
  }
}

class _SliverExpandBox extends RenderProxyBox {
  AlignmentDirectional alignment;

  _SliverExpandBox({
    this.alignment = AlignmentDirectional.center,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void performLayout() {
    //获取到约束
    final sliverConstraints = findSliverConstraints();
    if (sliverConstraints == null) {
      super.performLayout();
    } else {
      final Size expandSize;
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
        child!.layout(
            BoxConstraints(
              maxWidth: expandSize.width,
              maxHeight: expandSize.height,
            ),
            parentUsesSize: true);
        alignChildOffset(alignment, expandSize, null, child: child);
      }
      size = expandSize;
    }
  }
}

extension SliverExpandWidgetEx on Widget {
  /// [SliverExpandWidget]扩展方法
  Widget sliverExpand() {
    return SliverExpandWidget(child: this);
  }
}
