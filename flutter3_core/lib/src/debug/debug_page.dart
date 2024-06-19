part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 调试界面, 包含很多调试相关的功能
class DebugPage extends StatefulWidget {
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
        final path = await cacheFilePath("ScreenCapture${nowTime()}.png");
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
        final w1 = SliverFillRemaining(
          child: "test".text(),
        );
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
  ];

  /// 自定义的调试动作
  static final List<DebugAction> debugActions = [];

  /// 在[DebugPage]中注册一个调试动作, 可以是一个按钮, 也可以是一个属性编辑tile
  static void addClickDebugAction(String label, ClickAction clickAction) {
    debugActions.add(DebugAction(
      label: label,
      clickAction: clickAction,
    ));
  }

  /// [debugActions]
  static void addHiveDebugAction(
    String label,
    String des,
    Type hiveType,
    String hiveKey,
    dynamic defHiveValue,
  ) {
    debugActions.add(DebugAction(
      label: label,
      des: des,
      hiveKey: hiveKey,
      hiveType: hiveType,
      defHiveValue: defHiveValue,
    ));
  }

  /// 显示在调试页面的底部的widget列表
  static final WidgetNullList debugLastWidgetList = [];

  /// 底部点击要复制的文本信息
  static String? debugLastCopyString;

  /// [debugLastCopyString]
  static String get lastDebugCopyString => stringBuilder((builder) {
        if (DebugPage.debugLastCopyString != null) {
          builder.append(DebugPage.debugLastCopyString!);
        }
        builder.newLineIfNotEmpty();
        builder.append(
            "${_currentLocale ?? ""} ${screenWidthPixel.round()}*${screenHeightPixel.round()} ${dpr}");
        builder.newLineIfNotEmpty();
        builder.append($coreKeys.deviceUuid);
      });

  static Locale? _currentLocale;

  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> with AbsScrollPage {
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

    //当前语言
    final currentLocale = Localizations.localeOf(context);
    DebugPage._currentLocale = currentLocale;

    final defClickList =
        DebugPage.defDebugActions.filter((item) => item.clickAction != null);
    final defHiveList =
        DebugPage.defDebugActions.filter((item) => item.hiveKey != null);

    final clickList =
        DebugPage.debugActions.filter((item) => item.clickAction != null);
    final hiveList =
        DebugPage.debugActions.filter((item) => item.hiveKey != null);

    return [
      if (defClickList.isNotEmpty)
        buildClickActionList(context, defClickList).wrap()!.paddingAll(kX),
      if (clickList.isNotEmpty)
        buildClickActionList(context, clickList).wrap()!.paddingAll(kX),
      if (defHiveList.isNotEmpty) ...buildHiveActionList(context, defHiveList),
      if (hiveList.isNotEmpty) ...buildHiveActionList(context, hiveList),
      [
        ...DebugPage.debugLastWidgetList,
        "$currentLocale ${screenWidthPixel.round()}*${screenHeightPixel.round()} ${dpr}"
            .text(style: globalTheme.textPlaceStyle),
        $coreKeys.deviceUuid.text(style: globalTheme.textPlaceStyle),
      ]
          .column()
          ?.matchParentWidth()
          .click(() {
            DebugPage.lastDebugCopyString.copy();
            toastBlur(text: "已复制");
          })
          .align(Alignment.bottomCenter)
          .rFill()
    ].filterNull();
  }

  WidgetList buildClickActionList(
    BuildContext context,
    List<DebugAction> clickList,
  ) {
    return [
      for (final action in clickList)
        GradientButton.normal(() {
          action.clickAction?.call(context);
        }, child: action.label!.text()),
    ];
  }

  WidgetList buildHiveActionList(
    BuildContext context,
    List<DebugAction> hiveList,
  ) {
    //debugger();
    return [
      for (final action in hiveList)
        if (action.hiveType == String)
          LabelSingleInputTile(
              label: action.label,
              hint: action.des,
              value: action.defHiveValue ?? action.hiveKey?.hiveGet<String>(),
              onChanged: (value) {
                action.hiveKey?.hivePut(value);
              })
        else if (action.hiveType == int)
          LabelNumberTile(
            label: action.label,
            des: action.des,
            value: action.defHiveValue ?? action.hiveKey?.hiveGet<int>(0) ?? 0,
            onChanged: (value) {
              action.hiveKey?.hivePut(value);
            },
          )
        else if (action.hiveType == double)
          LabelNumberTile(
            label: action.label,
            des: action.des,
            value: action.defHiveValue ??
                action.hiveKey?.hiveGet<double>(0.0) ??
                0.0,
            onChanged: (value) {
              action.hiveKey?.hivePut(value);
            },
          )
        else if (action.hiveType == bool)
          LabelSwitchTile(
              label: action.label,
              des: action.des,
              value: action.defHiveValue ??
                  action.hiveKey?.hiveGet<bool>(false) == true,
              onChanged: (value) {
                action.hiveKey?.hivePut(value);
              })
        else
          "不支持的类型:${action.label}:[${action.hiveType}]".text(),
    ];
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);
}

/// 调试动作
class DebugAction {
  /// 标签
  String? label;

  /// 描述
  String? des;

  /// 普通的按钮点击事件
  ClickAction? clickAction;

  //--

  /// 自动修改hive属性
  String? hiveKey;

  /// [hiveKey]属性对应的类型
  Type? hiveType;

  /// [hiveKey]对应的默认值
  dynamic defHiveValue;

  DebugAction({
    this.label,
    this.des,
    this.clickAction,
    this.hiveKey,
    this.hiveType,
    this.defHiveValue,
  });
}
