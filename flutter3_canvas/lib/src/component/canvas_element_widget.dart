part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/28
///
/// 用来预览[ElementPainter]的小部件
/// [CanvasElementAsyncWidget]
class CanvasElementWidget extends LeafRenderObjectWidget {
  final ElementPainter? elementPainter;
  final EdgeInsets? padding;
  final BoxFit? fit;

  const CanvasElementWidget(
    this.elementPainter, {
    super.key,
    this.padding = const EdgeInsets.all(kL),
    this.fit = BoxFit.contain,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      CanvasElementRenderObject(elementPainter, padding, fit);

  @override
  void updateRenderObject(
    BuildContext context,
    CanvasElementRenderObject renderObject,
  ) {
    renderObject
      ..elementPainter = elementPainter
      ..padding = padding
      ..fit = fit
      ..markNeedsPaint();
  }
}

class CanvasElementRenderObject extends RenderBox {
  ElementPainter? elementPainter;
  EdgeInsets? padding;
  BoxFit? fit;

  CanvasElementRenderObject(
    this.elementPainter,
    this.padding,
    this.fit,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    elementPainter?.let((painter) {
      final canvas = context.canvas;
      //debugger();
      painter.elementsBounds?.let((src) {
        final dst = offset & size;
        //canvas.drawRect(dst, Paint()..color = Colors.black12);
        //debugger();
        canvas.drawInRect(
          dst,
          src,
          () {
            painter.painting(canvas, const PaintMeta());
          },
          fit: fit,
          dstPadding: padding,
        );
      });

      //context.canvas.drawRect(offset & size, Paint());
    });
  }

  @override
  void performLayout() {
    if (elementPainter == null) {
      size = constraints.smallest;
    } else if (constraints.isTight) {
      size = constraints.biggest;
    } else {
      final elementsBounds = elementPainter?.elementsBounds;
      if (elementsBounds == null) {
        size = constraints.smallest;
      } else {
        size = constraints.constrainDimensions(
          elementsBounds.width,
          elementsBounds.height,
        );
      }
    }
  }
}

/// 异步加载[ElementPainter]的小部件
/// [CanvasElementWidget]
class CanvasElementAsyncWidget extends StatefulWidget {
  /// 异步加载
  final FutureOr<ElementPainter?> Function()? action;

  /// 直接指定, 优先级高于[action]
  final ElementPainter? elementPainter;

  /// 监听[AsyncSnapshot]变化
  final void Function(AsyncSnapshot<ElementPainter?>)? onSnapshotChanged;

  //--
  final Widget Function(BuildContext context, Object? error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  const CanvasElementAsyncWidget({
    super.key,
    this.action,
    this.elementPainter,
    this.onSnapshotChanged,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  @override
  State<CanvasElementAsyncWidget> createState() =>
      _CanvasElementAsyncWidgetState();
}

class _CanvasElementAsyncWidgetState extends State<CanvasElementAsyncWidget> {
  /// [_FutureBuilderState]
  Object? _activeCallbackIdentity;
  late AsyncSnapshot<ElementPainter?> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.elementPainter == null
        ? const AsyncSnapshot.nothing()
        : AsyncSnapshot.withData(ConnectionState.none, widget.elementPainter);
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didUpdateWidget(CanvasElementAsyncWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action == widget.action) {
      return;
    }
    if (_activeCallbackIdentity != null) {
      _unsubscribe();
      _snapshot = _snapshot.inState(ConnectionState.none);
    }
    _subscribe();
  }

  void _subscribe() {
    if (widget.action == null) {
      // There is no future to subscribe to, do nothing.
      return;
    }
    final Object callbackIdentity = Object();
    _activeCallbackIdentity = callbackIdentity;
    () async {
      return await widget.action!();
    }()
        .then<void>((ElementPainter? data) {
      if (_activeCallbackIdentity == callbackIdentity) {
        setState(() {
          _snapshot = AsyncSnapshot.withData(ConnectionState.done, data);
          widget.onSnapshotChanged?.call(_snapshot);
        });
      }
    }, onError: (Object error, StackTrace stackTrace) {
      if (_activeCallbackIdentity == callbackIdentity) {
        setState(() {
          _snapshot =
              AsyncSnapshot.withError(ConnectionState.done, error, stackTrace);
          widget.onSnapshotChanged?.call(_snapshot);
        });
      }
      assert(() {
        if (FutureBuilder.debugRethrowError) {
          Future<Object>.error(error, stackTrace);
        }
        return true;
      }());
    });
    // An implementation like `SynchronousFuture` may have already called the
    // .then closure. Do not overwrite it in that case.
    if (_snapshot.connectionState != ConnectionState.done) {
      _snapshot = _snapshot.inState(ConnectionState.waiting);
      widget.onSnapshotChanged?.call(_snapshot);
    }
  }

  void _unsubscribe() {
    _activeCallbackIdentity = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.elementPainter != null) {
      return CanvasElementWidget(widget.elementPainter);
    }
    //future
    if (_snapshot.hasError) {
      return widget.errorBuilder?.call(context, _snapshot.error) ??
          GlobalConfig.of(context)
              .errorPlaceholderBuilder(context, _snapshot.error);
    }
    if (_snapshot.hasData) {
      if (_snapshot.data == null) {
        return widget.emptyBuilder?.call(context) ??
            GlobalConfig.of(context).emptyPlaceholderBuilder(context, null);
      } else {
        return CanvasElementWidget(_snapshot.data);
      }
    }
    return widget.loadingBuilder?.call(context) ??
        GlobalConfig.of(context).loadingIndicatorBuilder(context, this, null);
  }
}
