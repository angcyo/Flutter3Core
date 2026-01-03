import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/31
///
/// 轻量级的[WidgetsApp]
/// - 不包含[Navigator]
/// - 不拦截[WillPopScope], 不处理系统的返回键
/// - 包含[Material]相关组件基础运行上下文
class SimpleApp extends StatefulWidget {
  /// [WidgetsApp.home]
  final Widget home;

  //MARK: - Localizations

  /// [WidgetsApp.locale]
  final Locale? locale;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;

  //MARK: - Overlay

  /// [Overlay.clipBehavior]
  final Clip clipBehavior;

  const SimpleApp({
    super.key,
    required this.home,
    this.locale,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[
      Locale('en', 'US'),
      Locale('zh', 'CN'),
    ],
    //--
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<SimpleApp> createState() => _SimpleAppState();
}

class _SimpleAppState extends State<SimpleApp> {
  //MARK: - Localizations

  // Combine the Localizations for Material with the ones contributed
  // by the localizationsDelegates parameter, if any. Only the first delegate
  // of a particular LocalizationsDelegate.type is loaded so the
  // localizationsDelegate parameter can be used to override
  // _MaterialLocalizationsDelegate.
  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates {
    return <LocalizationsDelegate<dynamic>>[
      if (widget.localizationsDelegates != null)
        ...widget.localizationsDelegates!,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      /*DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,*/
    ];
  }

  // LOCALIZATION
  late final LocalizationsResolver _localizationsResolver =
      LocalizationsResolver(
        locale: widget.locale,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localeResolutionCallback: widget.localeResolutionCallback,
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: widget.supportedLocales,
      );

  //MARK: - Overlay

  late GlobalKey<OverlayState> _overlayKey;

  /// The overlay this navigator uses for its visual presentation.
  OverlayState? get overlay => _overlayKey.currentState;

  Iterable<OverlayEntry> get _allRouteOverlayEntries {
    return <OverlayEntry>[
      OverlayEntry(builder: (BuildContext context) => widget.home),
    ];
  }

  @override
  void initState() {
    _overlayKey = GlobalKey<OverlayState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Overlay(
      key: _overlayKey,
      clipBehavior: widget.clipBehavior,
      initialEntries: overlay == null
          ? _allRouteOverlayEntries.toList(growable: false)
          : const <OverlayEntry>[],
    );
    /*if (widget.textStyle != null) {
      result = DefaultTextStyle(style: widget.textStyle!, child: result);
    }*/
    //--
    /*if (kDebugMode) {
      result = SemanticsDebugger(child: result);
    }*/

    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior(),
      child: SharedAppData(
        child: Shortcuts(
          debugLabel: '<Default WidgetsApp Shortcuts>',
          shortcuts: WidgetsApp.defaultShortcuts,
          // DefaultTextEditingShortcuts is nested inside Shortcuts so that it can
          // fall through to the defaultShortcuts.
          child: DefaultTextEditingShortcuts(
            child: Actions(
              actions: <Type, Action<Intent>>{
                ...WidgetsApp.defaultActions,
                ScrollIntent: Action<ScrollIntent>.overridable(
                  context: context,
                  defaultAction: ScrollAction(),
                ),
              },
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: TapRegionSurface(
                  child: ShortcutRegistrar(
                    child: ListenableBuilder(
                      listenable: _localizationsResolver,
                      builder: (BuildContext context, _) {
                        return Localizations(
                          isApplicationLevel: true,
                          locale: _localizationsResolver.locale,
                          delegates: _localizationsResolver
                              .localizationsDelegates
                              .toList(),
                          child: result,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
