# 2023-10-21

一些有意义的关键类收集

- `WidgetsBinding.instance.platformDispatcher.locale` 平台当前的语言

## AppLifecycleListener

生命周期监听

```dart
late final AppLifecycleListener_listener;
late AppLifecycleState? _state;

@override
void initState() {
  super.initState();
  _state = SchedulerBinding.instance.lifecycleState;
  _listener = AppLifecycleListener(
    onShow: () => _handleTransition('show'),
    onResume: () => _handleTransition('resume'),
    onHide: () => _handleTransition('hide'),
    onInactive: () => _handleTransition('inactive'),
    onPause: () => _handleTransition('pause'),
    onDetach: () => _handleTransition('detach'),
    onRestart: () => _handleTransition('restart'),
    // This fires for each state change. Callbacks above fire only for
    // specific state transitions.
    onStateChange: _handleStateChange,
  );
}

void _handleTransition(String name) {
  print("########################## main$name");
}
```

https://juejin.cn/post/7269644295588708413

- [AppLifecycleListener](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html)

## ShaderMask

着色器遮罩

```dart
void test() {
  ShaderMask(
    shaderCallback: (Rect bounds) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.red, Colors.blue, Colors.green],
      ).createShader(bounds);
    },
    blendMode: BlendMode.color,
    child: Image.asset('assets/images/b.jpg', fit: BoxFit.cover),
  );
}
```

https://juejin.cn/post/6847902216871739400

## 判断当前路由下面是否还有路由

```dart
void build(context) {
  Navigator.of(context).canPop();
  Navigator
      .of(context)
      .impliesAppBarDismissal; // 下方是否还有路由
}
```

# 杂料

```
/flutter/packages/flutter/lib/src/material/material_localizations.dart:33 //返回按钮的提示文本
```

# Widget

## IgnorePointer

忽略区域内的点击事件

`/flutter/packages/flutter/lib/src/rendering/proxy_box.dart:3608`

```dart 
@override
bool hitTest(BoxHitTestResult result, { required Offset position }) {
  return !ignoring && super.hitTest(result, position: position);
}
```

## 手势

`GestureDetector`内部使用`RawGestureDetector`内部使用`Listener`;

`class Listener extends SingleChildRenderObjectWidget`;

使用`RenderPointerListener`的`handleEvent` 方法实现手势;


