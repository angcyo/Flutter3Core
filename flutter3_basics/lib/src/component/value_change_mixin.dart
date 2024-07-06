part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/01
///
/// 在[State]中, 保持监听[Widget]中的初始化值和当前值
/// 并计算当前值和初始化是否发生了改变
/// 并保持只刷新自身的情况下保持ui
mixin ValueChangeMixin<T extends StatefulWidget, V> on State<T> {
  /// 初始化的值
  late V initialValueMixin;

  /// 当前的值
  late V currentValueMixin;

  /// 是否发生了改变
  bool get isValueChangedMixin => initialValueMixin != currentValueMixin;

  @override
  void initState() {
    updateInitialValueMixin();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    updateInitialValueMixin();
    super.didUpdateWidget(oldWidget);
  }

  /// 重写此方法, 初始化[initialValueMixin].[currentValueMixin]
  @overridePoint
  void updateInitialValueMixin() {
    initialValueMixin = getInitialValueMixin();
    currentValueMixin = initialValueMixin;
  }

  /// 重写此方法, 获取初始化的[initialValueMixin].值
  @initialize
  V getInitialValueMixin();
}
