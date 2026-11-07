import 'dart:ui';

import 'package:flame/components.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/06
///
/// 超出屏幕移除的效果
class OffScreenRemoveEffect extends Component {
  /// 屏幕 bounds, 不指定表示游戏世界
  Rect? bounds;

  OffScreenRemoveEffect({this.bounds});

  @override
  void update(double dt) {
    super.update(dt);
    final parent = findParent<PositionComponent>();
    if (parent != null) {
      final bounds = this.bounds ?? findGame()?.canvasSize.toRect();
      if (bounds != null) {
        if (!bounds.overlaps(parent.position.toPositionedRect(parent.size))) {
          parent.removeFromParent();
        }
      }
    }
  }
}
