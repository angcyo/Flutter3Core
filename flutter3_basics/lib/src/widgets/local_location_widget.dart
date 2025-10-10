part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/10
///
/// 元素本地位置发生改变通知的小部件
/// - 需要指定元素的key
/// - 支持元素位置更新时通知
/// - 支持元素卸载后的通知
class LocalLocationWidget extends SingleChildRenderObjectWidget {
  /// 位置改变时的通知器
  /// - 当元素位置发生改变时, 会通知此对象
  /// - 当元素卸载时, 值为null
  ///
  /// [WidgetsBinding.instance.schedulerPhase]
  final ValueNotifier<Rect?>? locationNotifier;

  /// 父级容器元素
  /// - 影响全局的起始位置
  final RenderObject? ancestor;

  final String? debugLabel;

  const LocalLocationWidget({
    required super.key,
    this.locationNotifier,
    this.ancestor,
    this.debugLabel,
    super.child,
  });

  @override
  LocalLocationRenderObject createRenderObject(BuildContext context) {
    return LocalLocationRenderObject(
      key: key,
      locationNotifier: locationNotifier,
      ancestor: ancestor,
      debugLabel: debugLabel,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    LocalLocationRenderObject renderObject,
  ) {
    renderObject
      .._key = key
      .._locationNotifier = locationNotifier
      .._ancestor = ancestor
      .._debugLabel = debugLabel;
  }
}

/// 将要销毁的 key
final Set<Key?> _pendingDisposeKeySet = {};

/// [CustomSingleChildLayout]
class LocalLocationRenderObject extends RenderProxyBox {
  Key? _key;
  ValueNotifier<Rect?>? _locationNotifier;
  RenderObject? _ancestor;
  String? _debugLabel;

  LocalLocationRenderObject({
    Key? key,
    ValueNotifier<Rect?>? locationNotifier,
    RenderObject? ancestor,
    String? debugLabel,
  }) : _key = key,
       _locationNotifier = locationNotifier,
       _ancestor = ancestor,
       _debugLabel = debugLabel;

  @override
  void detach() {
    if (_debugLabel != null) {
      l.w("[${classHash()}] detach key:${_key?.classHash()}");
    }
    debugger(when: _debugLabel != null);
    _pendingDisposeKeySet.add(_key);
    super.detach();
  }

  @override
  void dispose() {
    super.dispose();
    if (_debugLabel != null) {
      l.e("[${classHash()}] dispose key:${_key?.classHash()}");
    }
    if (_key != null && _pendingDisposeKeySet.contains(_key)) {
      debugger(when: _debugLabel != null);
      _pendingDisposeKeySet.remove(_key);
      //元素销毁了
      _locationNotifier?.value = null;
    }
  }

  @override
  void attach(PipelineOwner owner) {
    if (_debugLabel != null) {
      l.i("[${classHash()}] attach key:${_key?.classHash()}");
    }
    debugger(when: _debugLabel != null);
    if (_pendingDisposeKeySet.contains(_key)) {
      _pendingDisposeKeySet.remove(_key);
    }
    super.attach(owner);
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    if (_locationNotifier != null) {
      final bounds = getGlobalBounds(_ancestor);
      _locationNotifier?.value = bounds;
    }
  }
}

/// [ValueKey]
/*class LocalLocationValueKey<T> extends ValueKey<T> {
  /// 待销毁处理的key
  Key? _pendingKey;

  LocalLocationValueKey(super.value) {
    //debugger();
  }
}*/
class CacheValueKey<T, C> extends ValueKey<T> {
  /// 额外的缓存数据
  C? cache;

  CacheValueKey(super.value, this.cache) {
    //debugger();
  }
}

extension LocalLocationWidgetEx on Widget {
  /// 元素本地位置发生改变通知的小部件
  /// - [LocalLocationWidget]
  Widget localLocation({
    required Key? key,
    ValueNotifier<Rect?>? locationNotifier,
    RenderObject? ancestor,
    String? debugLabel,
  }) {
    return LocalLocationWidget(
      key: key,
      locationNotifier: locationNotifier,
      ancestor: ancestor,
      debugLabel: debugLabel,
      child: this,
    );
  }
}
