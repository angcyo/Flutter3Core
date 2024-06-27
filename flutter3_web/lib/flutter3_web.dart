library flutter3_web;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

part 'src/inapp/single_inappweb_page.dart';
part 'src/single_web_page.dart';
part 'src/webview_ex.dart';

extension WebViewEx on BuildContext {
  /// 打开一个简单的网页使用WebView
  /// Open a single webview page.
  Future<T?> openSingleWebView<T extends Object?>(String? url) {
    return pushWidget(
      /*SingleWebPage(
        url: url,
      ),*/
      SingleInAppWebPage(url: url),
    );
  }
}
