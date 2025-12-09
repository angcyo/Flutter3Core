part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 调试界面, 包含很多调试相关的功能
/// - 多指捏合进入Debug界面
/// - 多指长按截图分享
///
/// [NavigatorRouteOverlay] 导航路由调试信息
class DebugPage extends StatefulWidget {
  /// 使用[PinchGestureWidget]自动处理[DebugPage]页面
  ///
  /// ```
  /// DebugPage.wrap(
  ///   context,
  ///   MaterialApp(),
  /// );
  /// ```
  static Widget wrap(BuildContext context, Widget body, {bool enable = true}) {
    if (!enable) {
      return body;
    }

    $onGlobalAppContextChanged((ctx) {
      if (isDebug) {
        DebugOverlayButton.show(ctx);
      }
      if (isDebugType) {
        NavigatorRouteOverlay.show(ctx);
      }
    });

    return PinchGestureWidget(
      onPinchAction: () {
        assert(() {
          l.v("onPinchAction...捏合");
          return true;
        }());
        //context.findNavigatorState()?.pushWidget(const DebugPage());
        try {
          context.pushWidget(const DebugPage());
        } catch (e) {
          GlobalConfig.def.globalAppContext?.pushWidget(const DebugPage());
        }
      },
      multiLongPressDuration: 2.seconds,
      onMultiLongPressDurationAction: () {
        assert(() {
          l.v("onMultiLongPressDurationAction...多指长按");
          return true;
        }());
        context.longPressFeedback();
        ScreenCaptureOverlay.showScreenCaptureOverlay();
      },
      child: body,
    );
  }

  /// debug
  static void _toastWidgetInfo(dynamic widget) {
    final text = stringBuilder((builder) {
      try {
        builder.appendLine(widget?.runtimeType);
        builder.appendLine(widget);
        builder.append(widget?.toStringShort());
      } catch (e) {
        //print(e);
      }
    });
    l.d(text);
    toastInfo(text);
  }

  /// 默认的调试动作
  /// - [DebugOverlayButton.defDebugActions]
  /// - [DebugPage.defDebugActions]
  static final List<DebugAction> defDebugActions = [
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
      label: "logWidget",
      clickAction: (context) {
        toastInfo("${GlobalApp.logWidget()}");
      },
    ),
    DebugAction(
      label: "testWidgetMinify",
      clickAction: (context) {
        final w1 = SliverFillRemaining(child: "test".text());
        final w2 = OverlayEntry(builder: (context) => "test".text());
        final text =
            "${w1.runtimeType}\n$w1\n${w1.toStringShort()}\n${w2.runtimeType}\n$w2";
        l.d(text);
        toastInfo(text);
      },
    ),
    DebugAction(
      label: "findWidgetsAppElement",
      clickAction: (context) {
        final element = GlobalConfig.def.findWidgetsAppElement();
        _toastWidgetInfo(element);
      },
    ),
    DebugAction(
      label: "findOverlayState",
      clickAction: (context) {
        final element = GlobalConfig.def.findOverlayState();
        _toastWidgetInfo(element);
      },
    ),
    DebugAction(
      label: "findNavigatorState",
      clickAction: (context) {
        final element = GlobalConfig.def.findNavigatorState();
        _toastWidgetInfo(element);
      },
    ),
    DebugAction(
      label: "testModalRouteList",
      clickAction: (context) {
        final routeList = GlobalConfig.def.findModalRouteList();
        final text = routeList.join("\n");
        l.d(text);
        toastInfo(text);
      },
    ),
    DebugAction(
      label: "hive编辑",
      clickAction: (context) {
        context.pushWidget(const DebugHiveEditPage());
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
  /// - [hiveType]
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

  //--

  /// 显示在调试页面的底部的widget列表
  /// [_initDebugLastInfo]
  static final List<WidgetNullBuilder> debugLastWidgetBuilderList = [];

  /// - [buildDebugLastWidget]
  /// - [buildLastDebugCopyString]
  static Widget buildDebugLastWidget(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    //当前语言
    final currentLocale = Localizations.localeOf(context);
    DebugPage._currentLocale = currentLocale;
    return [
      //--
      for (final builder in DebugPage.debugLastWidgetBuilderList)
        builder(context),
      //--
      "$currentLocale ${screenWidthPixel.round()}*${screenHeightPixel.round()}/${deviceWidthPixel.round()}*${deviceHeightPixel.round()} $dpr"
          .text(style: globalTheme.textPlaceStyle, selectable: true),
      "$platformMediaQueryDataList".text(
        style: globalTheme.textPlaceStyle,
        textAlign: .center,
        selectable: true,
      ),
      //--
      $coreKeys.deviceUuid.text(
        selectable: true,
        style: globalTheme.textPlaceStyle.copyWith(
          color: globalTheme.accentColor,
        ),
      ),
    ].column()!.matchParentWidth().click(() {
      DebugPage.buildLastDebugCopyString(context).copy();
      toastBlur(text: "已复制");
    });
  }

  //--

  /// 底部点击要复制的文本信息
  /// [_initDebugLastInfo]
  static List<String? Function(BuildContext? context)>
  debugLastCopyStringBuilderList = [];

  /// [debugLastCopyString]
  /// - [buildDebugLastWidget]
  /// - [buildLastDebugCopyString]
  static String buildLastDebugCopyString(BuildContext? context) {
    return stringBuilder((builder) {
      //--
      for (final b in debugLastCopyStringBuilderList) {
        builder.append(b(context));
      }
      //--
      builder.newLineIfNotEmpty();
      builder.append(
        "${_currentLocale ?? ""} ${screenWidthPixel.round()}*${screenHeightPixel.round()}/${deviceWidthPixel.round()}*${deviceHeightPixel.round()} $dpr",
      );
      builder.append("$platformMediaQueryDataList");
      //--
      builder.newLineIfNotEmpty();
      builder.append($coreKeys.deviceUuid);
    });
  }

  static Locale? _currentLocale;

  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage>
    with AbsScrollPage, DebugActionMixin {
  @override
  String? getTitle(BuildContext context) => "调试界面";

  @override
  void initState() {
    super.initState();
  }

  @override
  WidgetList? buildScrollBody(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = GlobalTheme.of(context);

    final defClickList = DebugPage.defDebugActions.filter(
      (item) => item.clickAction != null,
    );
    final defHiveList = DebugPage.defDebugActions.filter(
      (item) => item.hiveKey != null,
    );

    final clickList = DebugPage.debugActions.filter(
      (item) => item.clickAction != null,
    );
    final hiveList = DebugPage.debugActions.filter(
      (item) => item.hiveKey != null,
    );

    return [
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
      if (defHiveList.isNotEmpty) ...buildHiveActionList(context, defHiveList),
      if (hiveList.isNotEmpty) ...buildHiveActionList(context, hiveList),
      DebugPage.buildDebugLastWidget(
        context,
        globalTheme,
      ).align(Alignment.bottomCenter).rFill(),
    ].filterNull();
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);
}

/// hive 编辑界面
/// [CoreDebug.parseHiveKeys]
class DebugHiveEditPage extends StatefulWidget {
  const DebugHiveEditPage({super.key});

  @override
  State<DebugHiveEditPage> createState() => _DebugHiveEditPageState();
}

class _DebugHiveEditPageState extends State<DebugHiveEditPage>
    with AbsScrollPage {
  @override
  String? getTitle(BuildContext context) => "hive key-value";

  @override
  List<Widget>? buildAppBarActions(BuildContext context) {
    const Widget add = Icon(Icons.add);
    return [
      add.icon(() {
        context.showWidgetDialog(
          SingleInputDialog(
            title: "请输入",
            hintText: "格式: @key#type=value",
            alignment: Alignment.bottomCenter,
            useIcon: true,
            onSaveTap: (text) async {
              final (key, type, value) = CoreDebug.parseHiveKey(text);
              if (isNil(key) || isNil(type)) {
                toastInfo("格式错误");
                return true;
              } else {
                key?.hivePut(value);
                updateState();
                return false;
              }
            },
          ),
        );
      }),
    ];
  }

  @override
  WidgetList? buildScrollBody(BuildContext context) {
    final map = hiveAll();
    WidgetList list = [];
    map?.forEach((key, value) {
      if (value is String) {
        list.add(
          LabelSingleInputTile(
            label: key,
            inputText: value,
            onInputTextChanged: (value) {
              key.hivePut(value);
            },
          ),
        );
      } else if (value is int) {
        list.add(
          LabelNumberTile(
            label: key,
            value: value,
            onValueChanged: (value) {
              key.hivePut(value);
            },
          ),
        );
      } else if (value is double) {
        list.add(
          LabelNumberTile(
            label: key,
            value: value,
            onValueChanged: (value) {
              key.hivePut(value);
            },
          ),
        );
      } else if (value is bool) {
        list.add(
          LabelSwitchTile(
            label: key,
            value: value,
            onValueChanged: (value) {
              key.hivePut(value);
            },
          ),
        );
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);
}

extension DebugPageWidgetEx on Widget {
  /// 添加调试相关页面
  /// [DebugPage]
  Widget wrapDebugPage(BuildContext context, {bool enable = true}) =>
      DebugPage.wrap(context, this, enable: enable);
}
