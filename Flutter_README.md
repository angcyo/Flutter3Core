# 2023-11-9

直接打包`apk`体积大约`17MB`, 加入一些基础库之后`apk`体积大约`24.5MB`

- `lib\x86_64\libflutter.so`      4.7MB
- `lib\arm64-v8a\libflutter.so`   4.6MB
- `lib\armeabi-v7a\libflutter.so` 3.9MB

- `lib\x86_64\libapp.so`          965.6KB  2.8MB
- `lib\arm64-v8a\libapp.so`       958.8KB  2.8MB
- `lib\armeabi-v7a\libapp.so`     1.1MB    3.1MB

# RenderObject

## `sizedByParent`

`sizedByParent`为`true`时表示：当前组件的大小只取决于父组件传递的约束，而不会依赖后代组件的大小。

https://book.flutterchina.club/chapter14/layout.html#_14-4-5-sizedbyparent

## `parentUsesSize`

`parentUseSize`为`false`时，子组件的布局边界会是它自身，子组件布局发生变化后不会影响当前组件

# BuildContext

## getInheritedWidgetOfExactType

`getInheritedWidgetOfExactType`方法可以方便的获取`context`中的`InheritedWidget`，

## dependOnInheritedWidgetOfExactType

`dependOnInheritedWidgetOfExactType`方法可以方便的获取`context`中的`InheritedWidget`，
并在`InheritedWidget`发生变化时重新构建`Widget`树。


## findAncestorWidgetOfExactType

`findAncestorWidgetOfExactType`方法可以从当前节点沿着`Widget`树向上查找指定类型的`Widget`，

## findAncestorStateOfType

`findAncestorStateOfType`方法可以从当前节点沿着`Element`树向上查找指定类型的`State`对象，

##  findRootAncestorStateOfType

`findRootAncestorStateOfType`方法可以从当前节点沿着`Element`树向上查找根节点开始的第一个指定类型的`State`对象，

## findAncestorRenderObjectOfType

`findAncestorRenderObjectOfType`方法可以从当前节点沿着`RenderObject`树向上查找指定类型的`RenderObject`对象，

## visitAncestorElements

`visitAncestorElements`方法可以从当前节点沿着`Element`树向上遍历，直到某个节点满足某个条件为止。

## visitChildElements

`visitChildElements`方法可以遍历当前节点的所有子节点。