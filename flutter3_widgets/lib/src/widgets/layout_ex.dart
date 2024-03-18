part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///

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
