part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///

/// 布局约束
class LayoutBoxConstraints extends BoxConstraints {
  /// 自身的宽度是否包裹内容
  final bool? wrapContentWidth;

  /// 自身的高度是否包裹内容
  final bool? wrapContentHeight;

  /// 自身的宽度是否占满父布局的有效宽度
  final bool? matchParentWidth;

  /// 自身的高度是否占满父布局的有效高度
  final bool? matchParentHeight;

  const LayoutBoxConstraints({
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    this.wrapContentWidth,
    this.wrapContentHeight,
    this.matchParentWidth,
    this.matchParentHeight,
  });

  @override
  BoxConstraints copyWith({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    bool? wrapContentWidth,
    bool? wrapContentHeight,
    bool? matchParentWidth,
    bool? matchParentHeight,
  }) {
    return LayoutBoxConstraints(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      wrapContentWidth: wrapContentWidth ?? this.wrapContentWidth,
      wrapContentHeight: wrapContentHeight ?? this.wrapContentHeight,
      matchParentWidth: matchParentWidth ?? this.matchParentWidth,
      matchParentHeight: matchParentHeight ?? this.matchParentHeight,
    );
  }

  /// 约束计算自身的大小
  /// [parentConstraints] parent给自身的约束
  /// [childSize] 子节点的大小
  /// [padding] 内边距, 在[wrapContentWidth].[wrapContentHeight]时有效
  ///
  /// [BoxConstraints.isSatisfiedBy] 是否是满意的约束, 满足约束
  ///
  Size constrainSize(
    BoxConstraints parentConstraints,
    Size childSize,
    EdgeInsets? padding,
  ) {
    if (parentConstraints.isTight) {
      return parentConstraints.constrain(childSize);
    }

    final paddingHorizontal = padding?.horizontal ?? 0;
    final paddingVertical = padding?.vertical ?? 0;

    final childWidth = childSize.width + paddingHorizontal;
    final childHeight = childSize.height + paddingVertical;

    double width = parentConstraints.constrainWidth(childWidth);
    double height = parentConstraints.constrainWidth(childHeight);

    if (wrapContentWidth == true) {
      width = constrainWidth(childWidth);
    } else if (matchParentWidth == true) {
      if (parentConstraints.maxWidth != double.infinity) {
        width = parentConstraints.maxWidth;
      } else if (maxWidth != double.infinity) {
        width = maxWidth;
      } else {
        assert(() {
          debugPrint(
              'matchParentWidth is true, but parentConstraints.maxWidth is double.infinity');
          return true;
        }());
      }
    }

    if (wrapContentHeight == true) {
      height = constrainHeight(childHeight);
    } else if (matchParentHeight == true) {
      if (parentConstraints.maxHeight != double.infinity) {
        height = parentConstraints.maxHeight;
      } else if (maxHeight != double.infinity) {
        height = maxHeight;
      } else {
        assert(() {
          debugPrint(
              'matchParentHeight is true, but parentConstraints.maxHeight is double.infinity');
          return true;
        }());
      }
    }

    return Size(width, height);
  }
}

mixin LayoutMixin<ChildType extends RenderObject,
        ParentDataType extends ContainerParentDataMixin<ChildType>>
    on ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// 获取所有的子节点
  /// [RenderBoxContainerDefaultsMixin.getChildrenAsList]
  @protected
  List<ChildType> getChildren() {
    final List<ChildType> result = <ChildType>[];
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData =
          child.parentData! as ParentDataType;
      result.add(child);
      child = childParentData.nextSibling;
    }
    return result;
  }

  /// 枚举所有的子节点
  @protected
  void eachChild(void Function(ChildType child) action) {
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType parentData = child.parentData as ParentDataType;
      action(child);
      child = parentData.nextSibling;
    }
  }

  /// 枚举所有的子节点, 并且返回索引
  /// [eachChild]
  @protected
  void eachChildIndex(void Function(ChildType child, int index) action) {
    ChildType? child = firstChild;
    int index = 0;
    while (child != null) {
      final ParentDataType parentData = child.parentData as ParentDataType;
      action(child, index);
      child = parentData.nextSibling;
      index++;
    }
  }
}

/// 对齐子元素, 通过修改[child!.parentData]这样的方式手势碰撞就会自动计算
/// [AlignmentDirectional]
/// [Alignment]
Offset alignChildOffset(
  AlignmentGeometry alignment,
  Size containsSize,
  Size childSize, {
  RenderBox? child,
}) {
  var dx = 0.0;
  var dy = 0.0;
  switch (alignment) {
    case AlignmentDirectional.topStart:
    case AlignmentDirectional.centerStart:
    case AlignmentDirectional.bottomStart:
    case Alignment.topLeft:
    case Alignment.centerLeft:
    case Alignment.bottomLeft:
      dx = 0;
      break;
    case AlignmentDirectional.topCenter:
    case AlignmentDirectional.center:
    case AlignmentDirectional.bottomCenter:
    case Alignment.topCenter:
    case Alignment.center:
    case Alignment.bottomCenter:
      dx = (containsSize.width - childSize.width) / 2;
      break;
    case AlignmentDirectional.topEnd:
    case AlignmentDirectional.centerEnd:
    case AlignmentDirectional.bottomEnd:
    case Alignment.topRight:
    case Alignment.centerRight:
    case Alignment.bottomRight:
      dx = containsSize.width - childSize.width;
      break;
  }
  switch (alignment) {
    case AlignmentDirectional.topStart:
    case AlignmentDirectional.topCenter:
    case AlignmentDirectional.topEnd:
    case Alignment.topLeft:
    case Alignment.topCenter:
    case Alignment.topRight:
      dy = 0;
      break;
    case AlignmentDirectional.centerStart:
    case AlignmentDirectional.center:
    case AlignmentDirectional.centerEnd:
    case Alignment.centerLeft:
    case Alignment.center:
    case Alignment.centerRight:
      dy = (containsSize.height - childSize.height) / 2;
      break;
    case AlignmentDirectional.bottomStart:
    case AlignmentDirectional.bottomCenter:
    case AlignmentDirectional.bottomEnd:
    case Alignment.bottomLeft:
    case Alignment.bottomCenter:
    case Alignment.bottomRight:
      dy = containsSize.height - childSize.height;
      break;
  }
  final offset = Offset(dx, dy);
  if (child != null && child.parentData is BoxParentData) {
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    childParentData.offset = offset;
  }
  return offset;
}
