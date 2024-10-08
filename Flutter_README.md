# 2023-11-9

```dart
/// 条件导出: 如果有`dart.library.html`包, 则导入`_http_web.dart`, 否则导入`_http_io.dart`
export '_http_io.dart' if (dart.library.html) '_http_web.dart';

/// 2:
export 'dart:io' if (dart.library.html) 'web.dart';

/// 条件导入:
import 'factory_stub.dart' if (dart.library.io) 'gl_canvas_io.dart' if (dart.library.html) 'gl_canvas_web.dart';

/// 2:
import 'dio/dio_for_native.dart' if (dart.library.html) 'dio/dio_for_browser.dart';
```

直接打包`apk`体积大约`17MB`, 加入一些基础库之后`apk`体积大约`24.5MB`

## libflutter.so

- `lib\arm64-v8a\libflutter.so`   4.6MB
- `lib\armeabi-v7a\libflutter.so` 3.9MB
- `lib\x86_64\libflutter.so`      4.7MB

## libapp.so

- `lib\arm64-v8a\libapp.so`       958.8KB 2.8MB
- `lib\armeabi-v7a\libapp.so`     1.1MB 3.1MB
- `lib\x86_64\libapp.so`          965.6KB 2.8MB

# RenderObject

https://book.flutterchina.club/chapter14/render_object.html

## `sizedByParent`

`sizedByParent`为`true`时表示：当前组件的大小只取决于父组件传递的约束，而不会依赖后代组件的大小。

https://book.flutterchina.club/chapter14/layout.html#_14-4-5-sizedbyparent

## `parentUsesSize`

`parentUseSize`为`false`时，子组件的布局边界会是它自身，子组件布局发生变化后不会影响当前组件

## `performResize`

根据`layout()` 源码可以看出只有 `sizedByParent` 为 `true` 时，`performResize()` 才会被调用，而
`performLayout()` 是每次布局都会被调用的。

## `computeDryLayout`

https://juejin.cn/post/7049563669562146846

设置当前元素的宽高，遵守父组件的约束.

按照 Flutter 框架约定，我们应该重写 computeDryLayout 方法，而不是 performResize 方法。

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

## findRootAncestorStateOfType

`findRootAncestorStateOfType`方法可以从当前节点沿着`Element`
树向上查找根节点开始的第一个指定类型的`State`对象，

## findAncestorRenderObjectOfType

`findAncestorRenderObjectOfType`方法可以从当前节点沿着`RenderObject`
树向上查找指定类型的`RenderObject`对象，

## visitAncestorElements

`visitAncestorElements`方法可以从当前节点沿着`Element`树向上遍历，直到某个节点满足某个条件为止。

## visitChildElements

`visitChildElements`方法可以遍历当前节点的所有子节点。


# Widget

## StatelessWidget

`createElement`->`StatelessElement`

`StatelessElement.build`又强制调用`(widget as StatelessWidget).build(this)`;

## StatefulWidget

`createElement`->`StatefulElement`

`StatefulElement`构造时直接调用`widget.createState()`并存储在`StatefulElement._state`;

`StatefulElement.build`又直接调用`state.build(this)`;

## RenderObjectWidget

`RenderObjectElement`
`RenderObjectElement._renderObject`

- [LeafRenderObjectWidget]
- [SingleChildRenderObjectWidget]
- [MultiChildRenderObjectWidget]

此对象才有`RenderObject createRenderObject(BuildContext context)`, 才能通过`RenderObject`绘制东西;

# dependencies

https://dart.dev/tools/pub/dependencies

```yaml
dependencies:
  transmogrify: ^1.4.0
```

```yaml
dependencies:
  kittens:
    git: https://github.com/munificent/kittens.git
```

```yaml
dependencies:
  kittens:
    git:
      url: git@github.com:munificent/kittens.git
      ref: some-branch
```

```yaml
dependencies:
  kittens:
    git:
      url: git@github.com:munificent/cats.git
      path: path/to/kittens
```