import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/25
///
/// 在界面上浮动一个调试按钮
class DebugOverlayButton extends StatefulWidget {
  //region 显示

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

  //endregion 显示

  //region action配置

  /// 默认的调试动作
  /// - [DebugOverlayButton.defDebugActions]
  /// - [DebugPage.defDebugActions]
  static final List<DebugAction> defDebugActions = [
    DebugAction(
      label: "切换ThemeMode",
      clickAction: (context) {
        final globalConfig = GlobalConfig.of(context);
        globalConfig.updateThemeAction(() {
          if (globalConfig.themeMode != ThemeMode.dark) {
            globalConfig.themeMode = ThemeMode.dark;
          } else {
            globalConfig.themeMode = ThemeMode.light;
          }
        });
      },
    ),
    DebugAction(
      label: "分享App日志",
      clickAction: (context) {
        final globalConfig = GlobalConfig.of(context);
        globalConfig.shareAppLogFn?.call(context, DebugAction);
      },
    ),
    DebugAction(
      label: "App文件管理",
      clickAction: (context) {
        context.pushWidget(const DebugFilePage()).get((value, error) {
          l.i("返回结果:$value");
        });
      },
    ),
    DebugAction(
      label: "截屏",
      clickAction: (context) async {
        final path = await cacheFilePath("ScreenCapture${nowTimestamp()}.png");
        final image = await saveScreenCapture(path);
        if (image == null) {
          toastInfo('截屏失败');
        } else if (context.isMounted) {
          final globalConfig = GlobalConfig.of(context);
          globalConfig.shareDataFn?.call(context, path.file());
          toastInfo('截屏成功:$path');
        }
      },
    ),
    DebugAction(
      label: "exitApp",
      clickAction: (context) {
        exitApp();
      },
    ),
  ];

  /// 自定义的调试动作
  static final List<DebugAction> debugActions = [];

  /// 在[DebugPage]中注册一个调试动作, 可以是一个按钮, 也可以是一个属性编辑tile
  static void addClickDebugAction(String label, ClickAction clickAction) {
    debugActions.add(DebugAction(label: label, clickAction: clickAction));
  }

  /// [debugActions]
  static void addHiveDebugAction(
    String label,
    String des,
    Type hiveType,
    String hiveKey,
    dynamic defHiveValue,
  ) {
    debugActions.add(
      DebugAction(
        label: label,
        des: des,
        hiveKey: hiveKey,
        hiveType: hiveType,
        defHiveValue: defHiveValue,
      ),
    );
  }

  //endregion action配置

  /// 浮窗实体, 用于移除浮窗
  final OverlayEntry entry;

  const DebugOverlayButton(this.entry, {super.key});

  @override
  State<DebugOverlayButton> createState() => _DebugOverlayButtonState();
}

class _DebugOverlayButtonState extends OverlayPositionState<DebugOverlayButton>
    with GlobalAppStateMixin {
  Offset? get hivePositionOffset =>
      "_key_debug_overlay_button_offset".hiveGet<String>()?.point;

  set hivePositionOffset(Offset? value) {
    "_key_debug_overlay_button_offset".hivePut(value?.listString);
  }

  /// 按钮的大小
  final buttonSize = 40.0;

  @override
  void initState() {
    super.initState();
    positionOffset = hivePositionOffset ?? Offset(0, $screenHeight * 4 / 5);
    onTapBody = () {
      //toast("click".text());
      //$globalDebugLabel = "debug";
      //_testGlobalTheme(context);
      buildContext?.showWidgetDialog(DebugOverlayDialog());
    };
  }

  @override
  void onUpdateOverlayPosition(Offset position) {
    super.onUpdateOverlayPosition(position);
    hivePositionOffset = position;
  }

  @override
  Widget buildOverlayBody(BuildContext context) {
    //debugger();
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = GlobalTheme.of(context);
    return Icon(
          Icons.bug_report,
          color: globalConfig.isThemeLight()
              ? globalTheme.icoNormalColor
              : null,
        )
        .box(size: buttonSize)
        .shadowCircle(decorationColor: globalTheme.themeWhiteColor);
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

/// [DebugOverlayButton]弹出的测试弹窗
class DebugOverlayDialog extends StatefulWidget with DialogMixin {
  @override
  TranslationType get translationType => TranslationType.translation;

  const DebugOverlayDialog({super.key});

  @override
  State<DebugOverlayDialog> createState() => _DebugOverlayDialogState();
}

class _DebugOverlayDialogState extends State<DebugOverlayDialog>
    with DebugActionMixin, GlobalAppStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final defClickList = DebugOverlayButton.defDebugActions.filter(
      (item) => item.clickAction != null,
    );
    final defHiveList = DebugOverlayButton.defDebugActions.filter(
      (item) => item.hiveKey != null,
    );

    final clickList = DebugOverlayButton.debugActions.filter(
      (item) => item.clickAction != null,
    );
    final hiveList = DebugOverlayButton.debugActions.filter(
      (item) => item.hiveKey != null,
    );

    return widget.buildBottomChildrenDialog(
      context,
      [
        if (defClickList.isNotEmpty)
          //库中默认的
          buildClickActionList(context, defClickList)
              .wrap()!
              .paddingOnly(all: kH)
              .backgroundColor(globalTheme.borderColor, fillRadius: kX)
              .paddingOnly(all: kL),
        if (clickList.isNotEmpty)
          //用户自定义的
          buildClickActionList(context, clickList)
              .wrap()!
              .paddingOnly(all: kH)
              .backgroundColor(globalTheme.borderColor, fillRadius: kX)
              .paddingOnly(all: kL),
        if (defHiveList.isNotEmpty)
          ...buildHiveActionList(context, defHiveList),
        if (hiveList.isNotEmpty) ...buildHiveActionList(context, hiveList),
      ].filterNull(),
      scrollChildIndex: 0,
      contentMaxHeight: 0.3,
      useRScroll: true,
    );
  }
}
