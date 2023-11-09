library flutter3_web;

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:webview_flutter/webview_flutter.dart';

export 'package:webview_flutter/webview_flutter.dart';

part 'src/single_web_page.dart';

extension WebViewEx on BuildContext {
  /// 打开一个简单的网页使用WebView
  /// Open a single webview page.
  Future<T?> openSingleWebview<T extends Object?>(String? url) {
    return pushWidget(
      SingleWebPage(
        url: url,
      ),
    );
  }
}
