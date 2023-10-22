# 2023-10-21

一些有意义的关键类收集

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



