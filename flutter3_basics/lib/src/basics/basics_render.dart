part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

extension ContainerRenderObjectMixinEx<ChildType extends RenderObject,
        ParentDataType extends ContainerParentDataMixin<ChildType>>
    on ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// 可以使用`for in`语法遍历所有的子元素
  Iterable<RenderObject> get childrenList sync* {
    RenderObject? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child as ChildType);
    }
  }

  /// 绘制时的遍历对象
  Iterable<RenderObject> get childrenInPaintOrderList sync* {
    RenderObject? child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child as ChildType);
    }
  }
}
