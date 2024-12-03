part of '../flutter3_web.dart';

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

  //region --ui--

  /// 构建加载进度小部件
  bool buildLoadProgressWidget;

  /// 构建刷新小部件
  bool buildRefreshWidget;

  //endregion --ui--

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

/// ```
/// if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
///   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
/// }
/// ```
/// [flutter_inappwebview]
mixin InAppWebViewStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey inAppWebViewKey = GlobalKey();

  /// 配置属性
  @configProperty
  WebviewConfig webConfigMixin = WebviewConfig();

  /// 页面控制, 自动获取
  @autoInjectMark
  InAppWebViewController? inAppWebViewController;

  /// webview设置
  InAppWebViewSettings inAppWebViewSettings = InAppWebViewSettings(
    isInspectable: isDebug,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
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
    applicationNameForUserAgent: "angcyo",
    supportMultipleWindows: false,
    hardwareAcceleration: false,
    overScrollMode: OverScrollMode.ALWAYS,
  );

  /// 刷新控制
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
  String? webViewUserAgentCache;

  /// 获取UA
  Future<String?> get getWebViewUserAgent async =>
      (await inAppWebViewController?.getSettings())?.userAgent;

  //--

  @override
  void initState() {
    super.initState();
    final globalTheme = GlobalTheme.of(context);
    webviewPullToRefreshController = isWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: globalTheme.accentColor,
            ),
            onRefresh: () async {
              if (isAndroid) {
                inAppWebViewController?.reload();
              } else if (isIos) {
                inAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(url: webviewUrl));
              }
            },
          );
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
  @api
  Widget buildInAppWebView(BuildContext context, WebviewConfig config) {
    final globalTheme = GlobalTheme.of(context);
    final urlRequest = !isNil(config.url)
        ? URLRequest(url: WebUri(config.url!))
        : URLRequest(body: (config.html ?? 'about:blank').bytes);
    //debugger();
    final webview = InAppWebView(
      key: inAppWebViewKey,
      initialUrlRequest: urlRequest,
      pullToRefreshController:
          config.buildRefreshWidget ? webviewPullToRefreshController : null,
      initialSettings: inAppWebViewSettings,
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
            action: PermissionResponseAction.GRANT);
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
        l.d('onConsoleMessage:$consoleMessage');
        /*if (kDebugMode) {
          print(consoleMessage);
        }*/
      },
    );

    if (!config.buildLoadProgressWidget) {
      return webview;
    }
    final List<Widget> children = [];
    if (webviewLoadProgress > 0 && webviewLoadProgress < 100) {
      children.add(LinearProgressIndicator(
        value: webviewLoadProgress / 100,
        color: globalTheme.accentColor,
      ));
    }
    children.add(webview);
    if (config.debug) {
      //ua
      children.add(debugUpdateSignal
          .buildFn(() => webViewUserAgentCache?.text(
              style: globalTheme.textPlaceStyle.copyWith(fontSize: 9)))
          .position(alignBottom: true));
    }
    return Stack(children: children);
  }

  //region ---api---

  /// 按下返回键时, 等待页面back后返回
  /// @return true: webview已无back
  Future<bool> onWebviewBackPress() async {
    final canBack = await inAppWebViewController?.canGoBack();
    if (canBack == true) {
      inAppWebViewController?.goBack();
      return false;
    }
    return true;
  }

  /// 加载指定[url]
  Future<void> loadWebviewUrl(String url) async {
    return inAppWebViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)));
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
      webviewPullToRefreshController?.endRefreshing().ignore();
    }
    webviewLoadProgress = progress;
    webviewTile = await inAppWebViewController?.getTitle();
    webviewUrl = await inAppWebViewController?.getUrl();
    webviewOriginUrl = await inAppWebViewController?.getOriginalUrl();
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
  Future waitWebviewController(
      [FutureOr Function(InAppWebViewController controller)? action]) async {
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
  @overridePoint
  Future<NavigationActionPolicy?> onSelfShouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final uri = navigationAction.request.url!;
    l.d('shouldOverrideUrlLoading[${uri.scheme}]->$uri');
    if (await onSelfInterceptUri(uri)) {
      return NavigationActionPolicy.CANCEL;
    }
    if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
        .contains(uri.scheme)) {
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
    return false;
  }

//--
}
