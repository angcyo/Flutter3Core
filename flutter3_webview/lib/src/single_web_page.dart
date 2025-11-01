part of '../flutter3_webview.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/08
///
/// 简单的浏览web网页
/// [SingleWebPage]
/// [SingleInAppWebPage]
/// [webview_flutter]
@Deprecated("请使用SingleInAppWebPage")
class SingleWebPage extends StatefulWidget {
  const SingleWebPage({super.key, this.url, this.html, this.baseUrl});

  /// 需要加载的网页地址
  final String? url;

  /// 需要加载的网页内容
  final String? html;
  final String? baseUrl;

  @override
  State<SingleWebPage> createState() => _SingleWebPageState();
}

class _SingleWebPageState extends State<SingleWebPage> with AbsScrollPage {
  /// 标题
  String? _title = "loading...";

  /// 加载进度[0~1]
  double _progress = 0;

  //late WebViewController webViewController;

  /// 更新标题
  _updateTitleIfNeed() {
    /*webViewController.getTitle().then((value) {
      if (value != null && _title != value) {
        setState(() {
          _title = value;
        });
      }
    });*/
  }

  @override
  void initState() {
    super.initState();
    /*webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //..setUserAgent(userAgent)
      ..setBackgroundColor(const Color(0x00000000))
      //..addJavaScriptChannel(name, onMessageReceived: onMessageReceived)
      //..removeJavaScriptChannel(javaScriptChannelName)
      //..runJavaScriptReturningResult(javaScript)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            l.i('web onProgress: $progress');
            setState(() {
              _progress = progress / 100.0;
            });
            _updateTitleIfNeed();
          },
          onPageStarted: (url) {
            l.i('web onPageStarted: $url');
          },
          onPageFinished: (url) {
            l.i('web onPageFinished: $url');
            _updateTitleIfNeed();
          },
          onWebResourceError: (error) {
            l.e('web onWebResourceError: $error');
          },
          onUrlChange: (change) {
            l.i('web onUrlChange: $change');
          },
          onNavigationRequest: (request) {
            //baiduboxapp://utils?action=sendIntent
            l.d('请求加载:${request.url}');
            if (request.url.startsWith('http')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    if (widget.html?.isNotEmpty == true) {
      webViewController.loadHtmlString(widget.html!, baseUrl: widget.baseUrl);
    } else {
      var url = widget.url;
      if (url?.isEmpty == true) {
        webViewController.loadRequest('about:blank'.toUri()!);
      } else {
        webViewController.loadRequest(url!.toUri("http")!);
      }
    }*/
  }

  @override
  String? getTitle(BuildContext context) => _title ?? "";

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  @override
  Widget buildBody(BuildContext context, WidgetList? children) {
    List<Widget> children = [];
    if (_progress > 0 && _progress < 1) {
      children.add(LinearProgressIndicator(value: _progress));
    }
    //children.add(WebViewWidget(controller: webViewController));
    return Stack(children: children);
  }
}
