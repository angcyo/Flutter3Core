import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;
import 'package:flutter3_flame/flutter3_flame.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// 流式布局组件
/// - [PositionComponent]
///   - [LayoutComponent]
///     - [ColumnComponent]
///     - [RowComponent]
class FlowComponent extends LayoutComponent {
  FlowComponent({
    super.key,
    super.position,
    super.size,
    super.anchor = Anchor.topLeft,
    super.priority,
    required super.children,
    //--
    this.maxChildrenPerRow,
    this.mainAxisAlignment = .start,
    this.crossAxisAlignment = .start,
    this.rowCrossAxisAlignment = .start,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisMaxWidth,
    this.mainAxisMaxHeight,
    //--
    this.backgroundColor,
    this.debugLabel,
  });

  /// 主轴方向的对齐方式
  MainAxisAlignment mainAxisAlignment;

  /// 交叉轴方向的对齐方式
  CrossAxisAlignment crossAxisAlignment;

  /// 每行交叉轴的对齐方式
  CrossAxisAlignment rowCrossAxisAlignment;

  /// 主轴方向的最大宽度
  double? mainAxisMaxWidth;

  /// 主轴方向的最大高度
  double? mainAxisMaxHeight;

  /// 主轴方向的间距
  double mainAxisSpacing = 0.0;

  /// 交叉轴方向的间距
  double crossAxisSpacing = 0.0;

  /// 每行最多多少个child
  int? maxChildrenPerRow;

  /// 背景颜色
  Color? backgroundColor;

  String? debugLabel;

  @override
  Vector2 get intrinsicSize {
    double maxWidth = 0.0;
    double maxHeight = 0.0;
    for (final child in positionChildren) {
      final childSize = child.scaledSize;
      maxWidth = max(child.position.x + childSize.x, maxWidth);
      maxHeight = max(child.position.y + childSize.y, maxHeight);
    }
    return Vector2(
      mainAxisMaxWidth ?? maxWidth,
      mainAxisMaxHeight ?? maxHeight,
    );
  }

  List<List<PositionComponent>> _rowChildrenList = [];

  double? get _maxRefWidth {
    final gameSize = findGame()?.size;
    if (gameSize == null) {
      return null;
    }
    return gameSize.x - position.x;
  }

  double? get _maxRefHeight {
    final gameSize = findGame()?.size;
    if (gameSize == null) {
      return null;
    }
    return gameSize.y - position.y;
  }

  @override
  void layoutChildren() {
    final mainAxisWidth = mainAxisMaxWidth ?? _maxRefWidth ?? 0;
    debugger(when: mainAxisWidth <= 0);

    //先归纳每一行的元素
    double x = 0.0;
    _rowChildrenList = [];
    List<PositionComponent> rowChildren = [];
    for (final child in positionChildren) {
      final childSize = child.scaledSize;
      /*fb.l.d("[${child.runtimeType}]->$childSize");*/
      if ((maxChildrenPerRow != null &&
              rowChildren.length >= maxChildrenPerRow!) ||
          x + childSize.x > mainAxisWidth) {
        //新行
        if (rowChildren.isNotEmpty) {
          _rowChildrenList.add(rowChildren);
          rowChildren = [];
        }
        x = 0.0;
      }
      rowChildren.add(child);
    }
    if (rowChildren.isNotEmpty) {
      _rowChildrenList.add(rowChildren);
      rowChildren = [];
    }

    //布局每一行的元素
    final mainAxisHeight = mainAxisMaxHeight ?? _maxRefHeight ?? 0;
    debugger(when: mainAxisHeight <= 0);

    double rowY = switch (crossAxisAlignment) {
      .start => 0,
      .end => mainAxisHeight - getRowAllHeight(_rowChildrenList),
      .center => (mainAxisHeight - getRowAllHeight(_rowChildrenList)) / 2,
      .stretch => 0,
      .baseline => 0,
    };

    for (final rowChildren in _rowChildrenList) {
      double rowX = switch (mainAxisAlignment) {
        .start => 0,
        .end => mainAxisWidth - getRowWidth(rowChildren),
        .center => (mainAxisWidth - getRowWidth(rowChildren)) / 2,
        _ => 0,
      };
      final rowMaxHeight = getRowMaxHeight(rowChildren);
      for (final child in rowChildren) {
        final childSize = child.scaledSize;
        final newPosition = Vector2(rowX, rowY);

        double childOffsetY = switch (rowCrossAxisAlignment) {
          .start => 0,
          .end => rowMaxHeight - childSize.y,
          .center => (rowMaxHeight - childSize.y) / 2,
          _ => 0,
        };

        //child.position = newPosition;
        //child.topLeftPosition.setFrom(newPosition);
        final oldTopLeftPosition = child.topLeftPosition;
        final oldPosition = child.position;
        //final offset = Vector2(sx * childSize.x * ax, sy * childSize.y * ay);
        //child.position = newPosition;
        //debugger(when: debugMode == true);
        final offset = child.scaleOffset;
        child.topLeftPosition = newPosition + offset + Vector2(0, childOffsetY);
        if (debugLabel != null || debugMode == true) {
          fb.l.d(
            "[${child.runtimeType}]->childSize:${child.size} $childSize "
            "position:$oldPosition -> ${child.position} "
            "topLeftPosition:$oldTopLeftPosition -> ${child.topLeftPosition}",
          );
        }
        rowX += childSize.x + mainAxisSpacing;
      }
      rowY += rowMaxHeight + crossAxisSpacing;
    }

    //--
    size = Vector2(mainAxisWidth, mainAxisHeight);
  }

  /// 获取所有行的占用高度
  double getRowAllHeight(List<List<PositionComponent>> rowChildrenList) {
    double height = 0.0;
    for (final rowChildren in rowChildrenList) {
      final rowMaxHeight = getRowMaxHeight(rowChildren);
      height += rowMaxHeight + crossAxisSpacing;
    }
    if (rowChildrenList.length > 1) {
      height -= crossAxisSpacing;
    }
    return height;
  }

  /// 获取指定行最大的高度
  double getRowMaxHeight(List<PositionComponent> rowChildren) {
    double height = 0.0;
    for (final child in rowChildren) {
      height = max(child.scaledSize.y, height);
    }
    return height;
  }

  /// 获取指定行占用的宽度
  double getRowWidth(List<PositionComponent> rowChildren) {
    double width = 0.0;
    for (final child in rowChildren) {
      width += child.scaledSize.x + mainAxisSpacing;
    }
    if (rowChildren.length > 1) {
      width -= mainAxisSpacing;
    }
    return width;
  }

  //--

  @override
  void onGameResize(Vector2 size) {
    layoutChildren();
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (backgroundColor != null) {
      canvas.drawRect(size.toRect(), Paint()..color = backgroundColor!);
    }
  }

  /*Vector2? _tapDownPosition;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_tapDownPosition != null) {
      canvas.drawCircle(
        (_tapDownPosition! - position).toOffset(),
        30.0,
        Paint()..color = Colors.black12,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _tapDownPosition = event.canvasPosition;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _tapDownPosition = null;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    _tapDownPosition = null;
  }*/

  //--

  ///
  @override
  Vector2 localToParent(Vector2 point, {Vector2? output}) {
    return super.localToParent(point, output: output);
  }

  ///
  @override
  Vector2 parentToLocal(Vector2 point, {Vector2? output}) {
    return super.parentToLocal(point, output: output);
  }

  ///
  @override
  bool containsPoint(Vector2 point) {
    return super.containsPoint(point);
  }

  ///
  @override
  bool containsLocalPoint(Vector2 point) {
    return super.containsLocalPoint(point);
  }

  ///
  @override
  Iterable<Component> componentsAtPoint(
    Vector2 point, [
    List<Vector2>? nestedPoints,
  ]) {
    return super.componentsAtPoint(point, nestedPoints);
  }
}

/// 拦截手势事件的[FlowComponent]
class FlowTapComponent extends FlowComponent with TapCallbacks {
  FlowTapComponent({
    super.key,
    super.position,
    super.size,
    super.anchor = Anchor.topLeft,
    super.priority,
    required super.children,
    //--
    super.maxChildrenPerRow,
    super.mainAxisAlignment = .start,
    super.crossAxisAlignment = .start,
    super.mainAxisSpacing = 0.0,
    super.crossAxisSpacing = 0.0,
    super.mainAxisMaxWidth,
    super.mainAxisMaxHeight,
    //--
    super.backgroundColor,
    super.debugLabel,
  });
}
