part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/18
///
/// 调试模式下, 用来显示导航的路由栈信息以及一些额外的调试信息
/// [GlobalConfig.findModalRouteList]
class NavigatorRouteOverlay extends StatefulWidget {
  /// 是否显示了视图
  static bool _isShowNavigatorRouteOverlay = false;

  /// 显示左下角覆盖层小部件
  /// No Overlay widget found.
  /// Some widgets require an Overlay widget ancestor for correct operation.
  /// The most common way to add an Overlay to an application is to include a MaterialApp, CupertinoApp or
  /// Navigator widget in the runApp() call.
  static void showNavigatorRouteOverlay(BuildContext context) {
    if (_isShowNavigatorRouteOverlay) {
      return;
    }
    _isShowNavigatorRouteOverlay = true;
    postFrameCallback((_) {
      showOverlay((entry, state, context, progress) {
        return NavigatorRouteOverlay(entry);
      }, context: context);
    });
  }

  /// 圆圈的大小
  final double size;

  /// 交互的大小
  final double interactiveSize;

  final OverlayEntry entry;

  const NavigatorRouteOverlay(
    this.entry, {
    super.key,
    this.size = 12.0,
    this.interactiveSize = 40.0,
  });

  @override
  State<NavigatorRouteOverlay> createState() => _NavigatorRouteOverlayState();
}

enum _NavigatorRouteOverlayStateEnum {
  /// 正常状态
  normal,

  /// 显示路由栈信息
  routeStack,
}

class _NavigatorRouteOverlayState extends State<NavigatorRouteOverlay>
    with NavigatorObserverMixin {
  /// 当前显示状态
  _NavigatorRouteOverlayStateEnum showState =
      _NavigatorRouteOverlayStateEnum.normal;

  @override
  void reassemble() {
    super.reassemble();
    _updateIfNeed();
  }

  @override
  void onRouteDidPush(Route route, Route? previousRoute) {
    super.onRouteDidPush(route, previousRoute);
    _updateIfNeed();
  }

  @override
  void onRouteDidPop(Route route, Route? previousRoute) {
    super.onRouteDidPop(route, previousRoute);
    postDelayCallback(() {
      //等待路由动画结束
      _updateIfNeed();
    }, 360.milliseconds);
  }

  @override
  void onRouteDidRemove(Route route, Route? previousRoute) {
    super.onRouteDidRemove(route, previousRoute);
    _updateIfNeed();
  }

  @override
  void onRouteDidReplace({Route? newRoute, Route? oldRoute}) {
    super.onRouteDidReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateIfNeed();
  }

  @override
  void dispose() {
    NavigatorRouteOverlay._isShowNavigatorRouteOverlay = false;
    super.dispose();
  }

  /// 更新信息
  void _updateIfNeed() {
    //debugger();
    if (showState == _NavigatorRouteOverlayStateEnum.routeStack) {
      _routeTextSpan = null;
      updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (showState == _NavigatorRouteOverlayStateEnum.routeStack) {
      final globalTheme = GlobalTheme.of(context);
      result = _buildRouteState(context)
          .wrapTextStyle(
              style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: globalTheme.accentColor,
            shadows: const <Shadow>[
              Shadow(
                offset: Offset(1, 1),
                color: Colors.black,
                blurRadius: 2,
              ),
            ],
          ))
          .paddingAll(kM)
          .elevation(2.0)
          .animatedSize();
    } else {
      result = _buildNormalState(context);
    }
    return result
        .material()
        .doubleClick(
          () {
            try {
              widget.entry.remove();
              widget.entry.dispose();
            } catch (e) {
              assert(() {
                printError(e);
                return true;
              }());
            }
          },
          onTap: () {
            context.longPressFeedback();
            setState(() {
              if (showState == _NavigatorRouteOverlayStateEnum.routeStack) {
                _routeTextSpan = null;
              }
              showState = showState == _NavigatorRouteOverlayStateEnum.normal
                  ? _NavigatorRouteOverlayStateEnum.routeStack
                  : _NavigatorRouteOverlayStateEnum.normal;
            });
          },
        )
        .align(Alignment.bottomLeft)
        .safeArea(bottom: true);
  }

  /// 正常状态, 显示小圆点
  Widget _buildNormalState(BuildContext context) {
    final size = widget.size;
    final interactiveSize = widget.size;
    final globalTheme = GlobalTheme.of(context);
    return paintWidget(
      (canvas, size) {
        final radius = size.width / 2;
        final center = size.center(Offset.zero);
        canvas.drawCircle(
            center,
            radius,
            Paint()
              ..shader = radialGradientShader(
                  radius,
                  [
                    globalTheme.primaryColorDark,
                    globalTheme.primaryColor,
                    /*Colors.transparent,*/
                  ],
                  center: center)
              ..color = Colors.redAccent
              ..style = PaintingStyle.fill);
      },
      size: Size(size, size),
    ).align(Alignment.bottomLeft).size(size: interactiveSize);
  }

  Widget? _routeTextSpan;

  /// 路由状态信息
  Widget _buildRouteState(BuildContext context) {
    if (_routeTextSpan == null) {
      postFrameCallback((_) {
        final routeList = GlobalConfig.def.findModalRouteList();
        StringBuffer logBuffer = StringBuffer();
        _routeTextSpan = textSpanBuilder((builder) {
          bool isFirst = true;
          for (final part in routeList) {
            //debugger();
            if (!isFirst) {
              builder.newLine();
            }
            final route = part.$1;
            final element = part.$2;

            final name = route.settings.name;
            String? widgetName = element?.widget.runtimeType.toString();
            /*if (route is MaterialPageRoute) {
              widgetName = "${route.builder(context).runtimeType}";
            } else if (route is CupertinoPageRoute) {
              widgetName = "${route.builder(context).runtimeType}";
            } else {
              final Animation<double> animation = ProxyAnimation();
              widgetName =
                  "${route.buildPage(context, animation, animation).runtimeType}";
            }*/
            builder.addTextStyle(widgetName);
            if (name != null) {
              builder.addTextStyle("($name)");
            }
            //
            isFirst = false;
          }
        }, logBuffer: logBuffer);
        assert(() {
          l.i(logBuffer);
          return true;
        }());
        updateState();
      });
    }
    return _routeTextSpan ?? "...".text();
  }
}
