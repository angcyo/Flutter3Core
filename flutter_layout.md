# Flutter 布局相关内容

2025-1-4

## 无`child`布局, 也就是纯自绘小部件

### `Widget`

通常继承`LeafRenderObjectWidget`

### `Element`

使用对应的`LeafRenderObjectElement`

### `RenderObject`

继承`RenderBox`实现对应方法即可.



---

## 单`child`布局

实现一个`Widget`支持控制单个`child` `Widget`

### `Widget`

通常继承`SingleChildRenderObjectWidget`

### `Element`

使用对应的`SingleChildRenderObjectElement`

### `RenderObject`

继承`RenderProxyBox`实现对应方法即可.

- RenderBox
- RenderProxyBox
- RenderProxyBoxWithHitTestBehavior
- RenderConstrainedBox

关键混入`Mixin`:

- `RenderObjectWithChildMixin`
  - 负责`child` 成员属性
  - 负责`child.attach` `child.detach` `child.redepthChildren` `visitChildren` 回调的默认实现
- `RenderProxyBoxMixin`
  - 负责`setupParentData` `child.parentData` 赋值 
  - 负责`computeMin/MaxIntrinsicWidth` `computeMin/MaxIntrinsicHeight` `computeXXX` 回调的默认实现
  - 负责`applyPaintTransform` `performLayout` `hitTestChildren` `paint` 回调的默认实现

### `ParentData`

使用对应的`BoxParentData`



---

## 多`children`容器布局

实现一个`Widget`支持控制多个子`children` `Widget`

### `Widget`

通常继承`MultiChildRenderObjectWidget`

### `Element`

使用对应的`MultiChildRenderObjectElement`

- `mount`->`createRenderObject`->`attachRenderObject`->`insertRenderObjectChild`
- `update`->`canUpdate`->`updateRenderObject`->`updateChild`->`detachRenderObject`->`updateSlotForChild`->`updateSlot` ...
- `attachRenderObject/detachRenderObject/removeRenderObjectChild`
- `insertRenderObjectChild/moveRenderObjectChild`

### `RenderObject`

直接继承`RenderBox`实现对应方法即可.

关键混入`Mixin`:

- `ContainerRenderObjectMixin`
  - 负责`firstChild` `lastChild` `childCount` 成员属性
  - 负责`child.attach` `child.detach` `child.redepthChildren` `visitChildren` 回调的默认实现
  - 提供`insert/move` `add/remove` `addAll/removeAll` `childBefore/childAfter` 方法
- `RenderBoxContainerDefaultsMixin`
  - 提供`defaultHitTestChildren` `defaultPaint` `getChildrenAsList` 方法 

### `ParentData`

需要使用`ContainerBoxParentData`