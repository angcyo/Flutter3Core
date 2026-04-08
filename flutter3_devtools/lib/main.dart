import 'dart:io';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/04/08
///
/// https://pub.dev/packages/devtools_extensions
/// https://pub.dev/packages/devtools_app_shared
///
/// https://github.com/flutter/devtools/tree/master/packages/devtools_extensions/example/
///
/// https://github.com/flutter/flutter/blob/main/packages/flutter/lib/src/material/icons.dart
/// https://material.io/resources/icons
///
void main() {
  runApp(const Flutter3DevToolsExtension());
}

/// - [ExtensionManager]
///   - [extensionManager]
/// - [ServiceManager]
///   - [serviceManager]
/// - [DTDManager]
///   - [dtdManager]
class Flutter3DevToolsExtension extends StatelessWidget {
  const Flutter3DevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          extensionManager.showNotification(
            "isServiceAvailable:${serviceManager.isServiceAvailable}",
          );
          extensionManager.showNotification(
            "sdkVersion:${serviceManager.sdkVersion}",
          );
          extensionManager.showNotification(
            "connectedState:${serviceManager.connectedState.value}",
          );
          extensionManager.showBannerMessage(
            key: "banner",
            type: "warning",
            message: "Layout Banner Message",
            extensionName: "angcyo",
          );
          return Text(
            dtdManager.uri?.toString() ??
                serviceManager.connectedApp?.operatingSystem ??
                serviceManager.connectedApp?.flutterVersionNow?.toString() ??
                serviceManager.connectedApp?.toString() ??
                "angcyo devtools",
          );
        },
      ), // Build your extension here
    );
  }
}
