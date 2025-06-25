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

class _DebugOverlayButtonState extends State<DebugOverlayButton> {
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

    return Stack(
      children: [
        Positioned(
          left: offset.x,
          top: offset.y,
          child: Icon(Icons.bug_report).box(size: 40).shadowCircle().gesture(
            onPanUpdate: (details) {
              setState(() {
                offset = offset + details.delta;
              });
            },
            onTap: () {
              toast("click".text());
              $globalDebugLabel = "debug";
              final globalConfig = GlobalConfig.of(context);
              if (globalConfig.themeMode != ThemeMode.dark) {
                globalConfig.themeMode = ThemeMode.dark;
              } else {
                globalConfig.themeMode = ThemeMode.light;
              }
              if (globalConfig.locale == null) {
                globalConfig.locale = "en".toLocale();
              } else {
                globalConfig.locale = null;
              }
              globalConfig.notifyThemeChanged();
            },
          ),
        )
      ],
    );
  }
}
