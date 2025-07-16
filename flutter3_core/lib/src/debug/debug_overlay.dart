import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/25
///
/// 在界面上浮动一个调试按钮
class DebugOverlayButton extends StatefulWidget {
  /// 是否显示了视图
  static bool _isShow = false;

  /// 显示浮动按钮
  /// No Overlay widget found.
  /// Some widgets require an Overlay widget ancestor for correct operation.
  /// The most common way to add an Overlay to an application is to include a MaterialApp, CupertinoApp or
  /// Navigator widget in the runApp() call.
  static void show(BuildContext context) {
    if (_isShow) {
      return;
    }
    _isShow = true;
    postFrameCallback((_) {
      showOverlay((entry, state, context, progress) {
        return DebugOverlayButton(entry);
      }, context: context);
    });
  }

  /// 浮窗实体, 用于移除浮窗
  final OverlayEntry entry;

  const DebugOverlayButton(this.entry, {super.key});

  @override
  State<DebugOverlayButton> createState() => _DebugOverlayButtonState();
}

class _DebugOverlayButtonState extends State<DebugOverlayButton>
    with
        GlobalAppStateMixin,
        TickerProviderStateMixin,
        HookMixin,
        HookStateMixin {
  /// 按钮的大小
  final buttonSize = 40.0;

  /// 当前位置
  late Offset offset;

  @override
  void initState() {
    offset = Offset(0, $screenHeight / 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = GlobalTheme.of(context);
    return Stack(
      children: [
        Positioned(
          left: offset.x,
          top: offset.y,
          child: Icon(
            Icons.bug_report,
            color:
                globalConfig.isThemeLight() ? globalTheme.icoNormalColor : null,
          )
              .box(size: buttonSize)
              .shadowCircle(decorationColor: globalTheme.themeWhiteColor)
              .gesture(
            onPanUpdate: (details) {
              setState(() {
                offset = offset + details.delta;
              });
            },
            onPanStart: (details) {
              disposeAnyByKey("animation");
            },
            onPanEnd: (details) {
              _resetOffset();
            },
            onTap: () {
              //toast("click".text());
              //$globalDebugLabel = "debug";
              _testGlobalTheme(context);
            },
          ),
        )
      ],
    );
  }

  /// 归位, 自动贴边
  void _resetOffset() {
    final currentOffset = offset;
    final Offset targetOffset;
    if (offset.dx + buttonSize / 2 > $screenWidth / 2) {
      targetOffset = Offset($screenWidth - buttonSize, offset.dy);
    } else {
      targetOffset = Offset(0, offset.dy);
    }
    hookAnyByKey(
        "animation",
        animation(
          this,
          (value, isCompleted) {
            offset = lerpOffset(currentOffset, targetOffset, value);
            updateState();
          },
          curve: Curves.easeOut,
        ));
  }

  //--

  /// 测试主题改变功能
  void _testGlobalTheme(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    if (globalConfig.themeMode != ThemeMode.dark) {
      globalConfig.themeMode = ThemeMode.dark;
    } else {
      globalConfig.themeMode = ThemeMode.light;
    }
    /*if (globalConfig.locale == null) {
      globalConfig.locale = "en".toLocale();
    } else {
      globalConfig.locale = null;
    }*/
    globalConfig.notifyThemeChanged();
  }
}
