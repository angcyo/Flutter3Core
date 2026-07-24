part of '../flutter3_webview.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/27
///
/// 页面配置类
class WebviewConfig {
  /// 需要加载的网页地址
  String? url;

  /// 需要加载的网页内容字符串
  String? html;
  String? baseUrl;

  //region ui

  /// 构建加载进度小部件
  bool buildLoadProgressWidget;

  /// 构建刷新小部件
  bool buildRefreshWidget;

  //endregion ui

  /// 调试模式
  @flagProperty
  bool debug;

  WebviewConfig({
    this.url,
    this.html,
    this.baseUrl,
    this.buildRefreshWidget = false,
    this.buildLoadProgressWidget = true,
    this.debug = isDebug,
  });
}

/// [webview_flutter]
mixin WebViewStateMixin<T extends StatefulWidget> on State<T> {}

/// https://inappwebview.dev/docs/webview/in-app-webview/
/// ```
/// if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
///   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
/// }
/// ```
///
/// # 处理自定义Schemes
///
/// https://inappwebview.dev/docs/webview/in-app-webview/#handle-custom-schemes
///
/// [flutter_inappwebview]
mixin InAppWebViewStateMixin<T extends StatefulWidget> on State<T> {
  static WebViewEnvironment? sWebViewEnvironment;

  /// https://inappwebview.dev/docs/webview/in-app-webview/#handle-custom-schemes
  static Future<void> registerCustomSchemeEnvironment(
    List<String> schemes,
  ) async {
    if (isWindows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(
        availableVersion != null,
        'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.',
      );
      try {
        //PlatformException(0, Cannot create WebViewEnvironment: 组或资源的状态不是执行请求操作的正确状态。, null, null)
        //StandardMethodCodec.decodeEnvelope (package:flutter/src/services/message_codecs.dart:653:7)
        sWebViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(
            userDataFolder: null,
            customSchemeRegistrations: [
              for (final scheme in schemes)
                CustomSchemeRegistration(
                  scheme: scheme,
                  allowedOrigins: ['*'],
                  treatAsSecure: true,
                  hasAuthorityComponent: true,
                ),
            ],
          ),
        );
      } catch (e) {
        assert(() {
          print(e);
          return true;
        }());
      }
    }
  }

  //--

  final GlobalKey inAppWebViewKey = GlobalKey();

  /// 配置属性
  @configProperty
  WebviewConfig webConfigMixin = WebviewConfig();

  /// 页面控制, 自动获取
  @autoInjectMark
  InAppWebViewController? inAppWebViewController;

  /// webview是否创建完成
  bool get isWebViewCreated => inAppWebViewController != null;

  /// webview设置
  InAppWebViewSettings inAppWebViewSettings = InAppWebViewSettings(
    isInspectable: isDebug,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    useShouldInterceptRequest: true,
    useShouldOverrideUrlLoading: true,
    javaScriptEnabled: true,
    shouldPrintBackgrounds: true,
    transparentBackground: true,
    disableContextMenu: false,
    supportZoom: false,
    builtInZoomControls: false,
    displayZoomControls: false,
    alwaysBounceVertical: true,
    userAgent: null,
    //UA
    applicationNameForUserAgent: $customUserAgent ?? "angcyo",
    //附加的UA
    supportMultipleWindows: false,
    hardwareAcceleration: false,
    overScrollMode: OverScrollMode.ALWAYS,
  );

  /// 刷新控制
  /// https://inappwebview.dev/docs/webview/pull-to-refresh-controller
  @mobileFlag
  PullToRefreshController? webviewPullToRefreshController;

  /// debug刷新信号
  final debugUpdateSignal = createUpdateSignal();

  //--get

  /// 缓存的ua
  /// ```
  /// Mozilla/5.0 (Linux; Android 14; Pixel 6 Build/AP2A.240905.003.F1; wv)
  /// AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.107
  /// Mobile Safari/537.36 angcyo
  /// ```
  /// # Android
  /// ```
  /// Mozilla/5.0 (Linux; Android 16; Pixel 7a Build/BP3A.251005.004.B2; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.102 Mobile Safari/537.36 angcyo
  /// ```
  /// # Windows 11
  /// ```
  /// Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0
  /// ```
  String? webViewUserAgentCache;

  /// 获取UA
  Future<String?> get getWebViewUserAgent async {
    //MissingPluginException(No implementation found for method getDefaultUserAgent on channel com.pichillilorenzo/flutter_inappwebview_manager)
    assert(() {
      () async {
        if (!isWindows) {
          final defUserAgent =
              await InAppWebViewController.getDefaultUserAgent();
          l.d(defUserAgent);
        }
      }();
      return true;
    }());
    final setting = await inAppWebViewController?.getSettings();
    if (isWindows) {
      return (setting?.userAgent ?? "").connect(
        setting?.applicationNameForUserAgent,
      );
    }
    return setting?.userAgent;
  }

  //--

  @override
  void initState() {
    super.initState();
    final globalTheme = GlobalTheme.of(context);
    webviewPullToRefreshController =
        (isMobile && webConfigMixin.buildRefreshWidget)
        ? PullToRefreshController(
            settings: PullToRefreshSettings(color: globalTheme.accentColor),
            onRefresh: () async {
              if (isAndroid) {
                inAppWebViewController?.reload();
              } else if (isIos) {
                inAppWebViewController?.loadUrl(
                  urlRequest: URLRequest(url: webviewUrl),
                );
              }
            },
          )
        : null;
  }

  /// 构建脚手架
  @callPoint
  Widget buildInAppWebViewScaffold(
    BuildContext context, {
    WebviewConfig? config,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return Scaffold(
      backgroundColor: globalTheme.surfaceBgColor,
      body: buildInAppWebView(context, config ?? webConfigMixin)
          .interceptPopResult(() async {
            if (await onWebviewBackPress() == true) {
              buildContext?.pop();
            }
          }),
    );
  }

  /// 构建webview
  /// - 如果系统时间不对, 会导致webview加载失败.
  @api
  Widget buildInAppWebView(BuildContext context, WebviewConfig config) {
    //debugger();
    final globalTheme = GlobalTheme.of(context);
    final urlRequest = !isNil(config.url)
        ? URLRequest(url: WebUri(config.url!))
        : URLRequest(body: (config.html ?? 'about:blank').bytes);
    //debugger();
    final webview = InAppWebView(
      key: inAppWebViewKey,
      initialUrlRequest: urlRequest,
      pullToRefreshController: config.buildRefreshWidget
          ? webviewPullToRefreshController
          : null,
      initialSettings: inAppWebViewSettings,
      webViewEnvironment: webViewEnvironment ?? sWebViewEnvironment,
      onWebViewCreated: (controller) {
        l.d("onWebViewCreated");
        inAppWebViewController = controller;
        _handlePendingControllerCompleter(controller);
        () async {
          webViewUserAgentCache = await getWebViewUserAgent;
          if (config.debug) {
            debugUpdateSignal.update();
          }
        }();
        onSelfWebviewCreated();
      },
      onLoadStart: (controller, url) {
        l.d('onLoadStart:$url');
        onSelfWebviewProgress(0);
        /*setState(() {
          this.url = url.toString();
          inAppWebViewController?.text = this.url;
        });*/
      },
      onPermissionRequest: (controller, request) async {
        l.d('onPermissionRequest:$request');
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      shouldOverrideUrlLoading: onSelfShouldOverrideUrlLoading,
      onLoadStop: (controller, url) async {
        l.d('onLoadStop:$url');
        onSelfWebviewProgress(100);
        /*webviewPullToRefreshController?.endRefreshing().ignore();
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
        });*/
      },
      onReceivedError: (controller, request, error) {
        //WebResourceError{description: net::ERR_CONNECTION_TIMED_OUT, type: TIMEOUT}
        l.w('onReceivedError[${request.url}]:$error');
        webviewPullToRefreshController?.endRefreshing().ignore();
      },
      onProgressChanged: (controller, progress) async {
        l.d('onProgressChanged[${await controller.getTitle()}]->$progress');
        onSelfWebviewProgress(progress);
        /*if (progress == 100) {
          webviewPullToRefreshController?.endRefreshing().ignore();
        }
        setState(() {
          this.progress = progress / 100;
          urlController.text = url;
        });*/
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        l.d('onUpdateVisitedHistory:$url');
        /*setState(() {
          this.url = url.toString();
          urlController.text = this.url;
        });*/
      },
      onConsoleMessage: (controller, consoleMessage) {
        //onConsoleMessage:ConsoleMessage{message: request send [object Object] [object Object], messageLevel: LOG}
        if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
          l.e('onConsoleMessage:$consoleMessage');
        } else if (consoleMessage.messageLevel == ConsoleMessageLevel.WARNING) {
          l.w('onConsoleMessage:$consoleMessage');
        } else if (consoleMessage.messageLevel == ConsoleMessageLevel.TIP) {
          l.i('onConsoleMessage:$consoleMessage');
        } else {
          l.d('onConsoleMessage:$consoleMessage');
        }
        /*if (kDebugMode) {
          print(consoleMessage);
        }*/
      },
      onLoadResourceWithCustomScheme: (controller, request) async {
        l.d('onLoadResourceWithCustomScheme:$request');
        if (request.url.scheme == "angcyo") {
          /*final bytes = await rootBundle.load(
            "assets/${request.url.toString().replaceFirst("angcyo://", "", 0)}",
          );
          final response = CustomSchemeResponse(
            data: bytes.buffer.asUint8List(),
            contentType: "image/svg+xml",
            contentEncoding: "utf-8",
          );
          return response;*/
        }
        return null;
      },
    );

    if (!config.buildLoadProgressWidget) {
      return webview;
    }
    final List<Widget> children = [];
    if (webviewLoadProgress > 0 && webviewLoadProgress < 100) {
      children.add(
        LinearProgressIndicator(
          value: webviewLoadProgress / 100,
          color: globalTheme.accentColor,
        ),
      );
    }
    children.add(webview);
    if (config.debug) {
      //ua
      children.add(
        debugUpdateSignal
            .buildFn(
              () => webViewUserAgentCache?.text(
                style: globalTheme.textPlaceStyle.copyWith(fontSize: 6),
              ),
            )
            .position(alignBottom: true),
      );
    }
    return Stack(children: children);
  }

  /// 构建右侧菜单
  @api
  List<Widget>? buildWebViewActions(BuildContext context) {
    final libRes = context.libRes;
    final globalTheme = GlobalTheme.of(context);
    return [
      CapsuleButton(
        onEndTap: () {
          context.showWidgetDialog(
            BottomMenuItemsDialog([
              BottomMenuItemTile(
                closeAfterTap: true,
                child: [
                  webviewTile?.text(textAlign: .center),
                  webviewUrl?.text(
                    textStyle: globalTheme.textDesStyle,
                    textAlign: .center,
                  ),
                ].column(),
                onTap: () {
                  webviewUrl?.toString().copy();
                },
              ),
              if (webConfigMixin.debug || isDebugFlagDevice)
                BottomMenuItemTile(
                  closeAfterTap: true,
                  child: webViewUserAgentCache?.text(
                    textStyle: globalTheme.textDesStyle,
                    textAlign: .center,
                  ),
                  onTap: () {
                    webViewUserAgentCache?.copy();
                  },
                ),
              BottomMenuItemTile(
                enable: true,
                closeAfterTap: true,
                child: libRes?.libRefresh.text(),
                onTap: () {
                  reloadWebview();
                },
              ),
            ]),
          );
        },
      ),
    ];
  }

  //region ---api---

  /// 按下返回键时, 等待页面back后返回
  /// @return true: webview已无back
  @api
  Future<bool> onWebviewBackPress() async {
    final canBack = await inAppWebViewController?.canGoBack();
    if (canBack == true) {
      inAppWebViewController?.goBack();
      return false;
    }
    return true;
  }

  /// 加载指定[url]
  @api
  Future<void> loadWebviewUrl(String url) async {
    return inAppWebViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  /// 重新加载
  @api
  Future<void> reloadWebview() async {
    return inAppWebViewController?.reload();
  }

  /// 加载指定html数据[data]
  Future<void> loadWebviewHtml(String data) async {
    return inAppWebViewController?.loadData(data: data);
  }

  /// 加载指定html文件数据[data]
  Future<void> loadWebviewAssetFile(String assetFilePath) async {
    return inAppWebViewController?.loadFile(assetFilePath: assetFilePath);
  }

  /// 执行js,或者调用js中的方法
  /// [InAppWebViewController.evaluateJavascript]
  /// [InAppWebViewController.callAsyncJavaScript]
  Future evaluateJavascript(String source) async {
    return waitWebviewLoadFinish((_) {
      return inAppWebViewController?.evaluateJavascript(source: source);
    });
  }

  /// 添加一个方法到js层
  /// https://inappwebview.dev/docs/webview/javascript/communication
  /// ```
  /// window.flutter_inappwebview.callHandler(handlerName, ...args);
  /// window.myCustomObj = { callHandler: window.flutter_inappwebview.callHandler };
  /// window.myCustomObj.callHandler(...);
  /// ```
  void addJavaScriptHandler(
    String handlerName,
    JavaScriptHandlerCallback callback,
  ) {
    waitWebviewController((controller) {
      controller.addJavaScriptHandler(
        handlerName: handlerName,
        callback: callback,
      );
    });
  }

  /// 更新附加的 User Agent 信息
  @api
  Future<void> updateCustomUserAgent(String? userAgent) async {
    if (isWindows) {
      inAppWebViewSettings.userAgent =
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0${userAgent ?? ""}";
    }
    inAppWebViewSettings.applicationNameForUserAgent = userAgent;
    if (isWebViewCreated) {
      await inAppWebViewController?.setSettings(settings: inAppWebViewSettings);
      webViewUserAgentCache = await getWebViewUserAgent;
      if (webConfigMixin.debug) {
        debugUpdateSignal.update();
      }
      await reloadWebview();
    }
  }

  WebViewEnvironment? webViewEnvironment;

  //endregion ---api---

  //---

  /// [0~100]
  int webviewLoadProgress = -1;

  /// 标题
  String? webviewTile;

  /// 当前加载的链接
  WebUri? webviewUrl;

  /// 原始加载的链接
  WebUri? webviewOriginUrl;

  /// 更新加载进度, 并承载着加载完成的处理
  void updateWebviewProgress(int progress) async {
    if (progress >= 100) {
      _handlePendingPageCompleter(true);
    }
    if (webviewLoadProgress == progress) {
      return;
    }
    if (progress >= 100) {
      //A AndroidPullToRefreshController was used after being disposed.
      //Once the AndroidPullToRefreshController has been disposed, it can no longer be used.
      webviewPullToRefreshController?.endRefreshing().ignore();
    }
    webviewLoadProgress = progress;
    webviewTile = await inAppWebViewController?.getTitle();
    webviewUrl = await inAppWebViewController?.getUrl();
    //MissingPluginException(No implementation found for method getOriginalUrl on channel com.pichillilorenzo/flutter_inappwebview_2854456911840)
    try {
      webviewOriginUrl = await inAppWebViewController?.getOriginalUrl();
    } catch (e) {
      assert(() {
        print(e);
        return true;
      }());
      webviewOriginUrl ??= webviewUrl;
    }
    updateState();
  }

  //--

  /// 等待控制器完成
  /// [inAppWebViewController]
  /// [InAppWebViewController]
  final List<Completer> _pendingControllerCompleterList = [];

  /// 处理等待中的[Completer]
  void _handlePendingControllerCompleter(InAppWebViewController controller) {
    try {
      for (final completer in _pendingControllerCompleterList) {
        try {
          completer.complete(controller);
        } catch (e) {
          assert(() {
            printError(e);
            return true;
          }());
        }
      }
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
    } finally {
      _pendingControllerCompleterList.clear();
    }
  }

  @api
  Future waitWebviewController([
    FutureOr Function(InAppWebViewController controller)? action,
  ]) async {
    if (inAppWebViewController != null) {
      return action?.call(inAppWebViewController!);
    }
    final completer = Completer<InAppWebViewController>();
    _pendingControllerCompleterList.add(completer);
    final result = await completer.future;
    return action?.call(result);
  }

  //--

  /// 等待页面加载完成
  final List<Completer> _pendingPageCompleterList = [];

  /// 处理等待中的[Completer]
  @CallFrom("updateWebviewProgress")
  void _handlePendingPageCompleter(bool finish) {
    try {
      for (final completer in _pendingPageCompleterList) {
        try {
          completer.complete(finish);
        } catch (e) {
          assert(() {
            printError(e);
            return true;
          }());
        }
      }
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
    } finally {
      _pendingPageCompleterList.clear();
    }
  }

  /// 等待页面加载完成回调, 页面进度100%
  /// [_handlePendingPageCompleter]
  @api
  Future waitWebviewLoadFinish([FutureBoolAction? action]) async {
    if (webviewLoadProgress >= 100) {
      return action?.call(true);
    }
    final completer = Completer<bool>();
    _pendingPageCompleterList.add(completer);
    final result = await completer.future;
    return action?.call(result == true);
  }

  //--

  /// webview创建
  @overridePoint
  void onSelfWebviewCreated() {}

  /// 加载进度回调
  @overridePoint
  void onSelfWebviewProgress(int progress) {
    updateWebviewProgress(progress);
  }

  /// 拦截url
  /// ```
  /// laserabc://region/complete?payload=xxx
  /// ```
  @overridePoint
  Future<NavigationActionPolicy?> onSelfShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final uri = navigationAction.request.url!;
    l.d('shouldOverrideUrlLoading[${uri.scheme}]->$uri');
    if (await onSelfInterceptUri(uri)) {
      return NavigationActionPolicy.CANCEL;
    }
    if (![
      "http",
      "https",
      "file",
      "chrome",
      "data",
      "javascript",
      "about",
    ].contains(uri.scheme)) {
      //非上述的scheme, 都认为是App内部的scheme
      if (await uri.canLaunch()) {
        // Launch the App
        await uri.launch();
        // and cancel the request
      }
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  /// 拦截uri
  /// @return true:拦截[uri]的加载, false:不拦截
  @overridePoint
  Future<bool> onSelfInterceptUri(Uri uri) async {
    if ($shouldOverrideInterceptUri != null) {
      return $shouldOverrideInterceptUri!(uri);
    }
    return false;
  }

  //--
}
