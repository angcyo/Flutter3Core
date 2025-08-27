part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/08/27
///
/// 骨架小部件
class SkeletonWidget extends LeafRenderObjectWidget {
  final SkeletonData? data;

  const SkeletonWidget({super.key, this.data});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SkeletonRender(data: data);
  }

  @override
  void updateRenderObject(BuildContext context, SkeletonRender renderObject) {
    renderObject
      ..data = data
      ..markNeedsPaint();
  }
}

/// 渲染器
class SkeletonRender extends RenderBox {
  SkeletonData? data;

  SkeletonRender({this.data});

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    //debugger();
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //debugger();
    final canvas = context.canvas;
    canvas.drawColor(Colors.green, BlendMode.src);
  }
}

/// 骨架数据
///
/// 所有数值, 如果是<=1, 则表示在容器中的比例
/// 如果是 >1, 则表示dp值
///
class SkeletonData {
  /// 绘制的类型
  final SkeletonDataType type;

  /// 宽高
  final double width;
  final double height;

  /// 矩形的圆角
  final double rx;
  final double ry;

  /// 绘制时的左右上下边距
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// 子元素
  final List<SkeletonData>? children;

  SkeletonData({
    this.type = SkeletonDataType.none,
    this.width = 0,
    this.height = 0,
    //--
    this.rx = 0,
    this.ry = 0,
    //--
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    //--
    this.children,
  });
}

enum SkeletonDataType {
  /// 不绘制, 只定位
  none,

  /// 矩形
  rect,

  /// 圆形
  circle,
}
