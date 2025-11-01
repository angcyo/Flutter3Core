import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

part 'src/3d/flutter_3d_page.dart';
part 'src/single_inappweb_page.dart';
part 'src/single_web_page.dart';
part 'src/webview_ex.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/11/01
///
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
