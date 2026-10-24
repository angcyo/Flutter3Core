import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/24
///
/// 按照比例分离布局组件
class SplitLayout extends LayoutComponent {
  /// 分离比例, 不指定, 则均匀分布
  /// [1, 1] : 总空间占用多少份
  final List<int>? ratios;

  SplitLayout({
    super.key,
    super.position,
    super.size,
    super.anchor = .topLeft,
    super.priority,
    required super.children,
    //--
    this.ratios,
  });

  @override
  Vector2 get intrinsicSize {
    return Vector2(layoutSizeX ?? 0, layoutSizeY ?? 0);
  }

  @override
  void layoutChildren() {
    final totalParts = this.totalParts;
    int index = 0;
    double left = 0.0;
    final gameSize = findGame()?.size;
    final maxWidth =
        (intrinsicSize.x <= 0 ? gameSize?.x : intrinsicSize.x) ??
        findParent<PositionComponent>()?.size.y ??
        0;
    final maxHeight =
        (intrinsicSize.y <= 0 ? gameSize?.y : intrinsicSize.y) ??
        findParent<PositionComponent>()?.size.y ??
        0;
    final children = positionChildren;
    for (final child in children) {
      final partsForChild = this.partsForChild(index);
      final width = (partsForChild / totalParts) * maxWidth;
      final height = maxHeight;
      child.size = Vector2(width, height);
      child.position = Vector2(left, 0);
      left += width;
      index++;
    }
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    //no op
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    layoutChildren();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    super.onParentResize(maxSize);
    layoutChildren();
  }

  //--

  /// 总份数
  int get totalParts =>
      ratios?.fold(0, (a, b) => a! + b) ?? positionChildren.length;

  /// 指定child占用的份数
  int partsForChild(int index) => ratios?.getOrNull(index) ?? 1;
}
