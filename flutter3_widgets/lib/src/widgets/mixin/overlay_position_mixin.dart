part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/09/15
///
/// 在浮窗中, 自由移动位置的混入
mixin OverlayPositionMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T>, HookMixin, HookStateMixin<T> {
  /// 当前位置, 关键值
  late Offset positionOffset;

  /// 浮窗内容大小
  Size _overlayBodySize = Size.zero;

  /// 父容器的大小, 用于计算贴边时的判断
  Size _overlayContainerSize = Size.zero;

  //--

  /// 点击浮窗内容时的回调
  @configProperty
  GestureTapCallback? onTapBody;

  /// 调试标签
  String? debugLabel;

  //--

  /// 浮窗是否在容器右边
  bool get isOverlayInRight =>
      positionOffset.dx + _overlayBodySize.width / 2 >
      _overlayContainerSize.width / 2;

  @override
  void initState() {
    //初始化默认位置
    positionOffset = Offset(0, $screenHeight / 5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer(buildOverlayBody(context));
  }

  /// 构建浮窗内容
  @overridePoint
  Widget buildOverlayBody(BuildContext context) {
    return Placeholder();
  }

  //--

  /// 构建浮窗容器, 以便获取容器的信息, 方便在容器中贴边定位
  /// - 支持全屏容器
  /// - 支持局部容器
  ///
  /// - [buildContainer]
  /// - [wrapBody]
  @api
  Widget buildContainer(Widget body) {
    return AfterLayout(
      child: Stack(
        children: [
          Positioned(
            left: positionOffset.x,
            top: positionOffset.y,
            child: wrapBody(body),
          ),
        ],
      ),
      afterLayoutAction: (ctx, child) {
        debugger(when: debugLabel != null);
        _overlayContainerSize = child.size;
      },
    );
  }

  /// 包装body, 以便支持手势拖拽移动位置
  /// - [buildContainer]
  /// - [wrapBody]
  @api
  Widget wrapBody(Widget body) {
    return AfterLayout(
      child: body.gesture(
        onPanUpdate: (details) {
          onUpdateOverlayPosition(positionOffset + details.delta);
        },
        onPanStart: (details) {
          disposeAnyByKey("animation");
        },
        onPanEnd: (details) {
          resetOverlayOffset();
        },
        onTap: onTapBody,
      ),
      afterLayoutAction: (ctx, child) {
        debugger(when: debugLabel != null);
        _overlayBodySize = child.size;
      },
    );
  }

  //--

  /// 归位, 自动贴边处理
  void resetOverlayOffset() {
    final currentOffset = positionOffset;
    double targetX = currentOffset.dx;
    double targetY = currentOffset.dy;

    if (currentOffset.dx + _overlayBodySize.width / 2 >
        _overlayContainerSize.width / 2) {
      //需要向右贴边
      targetX = _overlayContainerSize.width - _overlayBodySize.width;
    } else {
      targetX = 0;
    }

    final minTop = $screenStatusBar;
    if (currentOffset.dy < minTop) {
      targetY = minTop;
    } else {
      final maxBottom = $screenHeight - $screenBottomBar;
      if (currentOffset.dy + _overlayBodySize.height > maxBottom) {
        targetY = maxBottom - _overlayBodySize.height;
      }
    }

    //使用动画移动归位
    hookAnyByKey(
      "animation",
      animation(this, (value, isCompleted) {
        onUpdateOverlayPosition(
          lerpOffset(currentOffset, Offset(targetX, targetY), value),
        );
      }, curve: Curves.easeOut),
    );
  }

  /// 当需要更新位置到[position]时触发
  @overridePoint
  void onUpdateOverlayPosition(Offset position) {
    setState(() {
      positionOffset = position;
    });
  }
}
