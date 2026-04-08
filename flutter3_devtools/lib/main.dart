import 'dart:io';

import 'package:devtools_app_shared/ui.dart';
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
/// # 程序中需要注册扩展 [registerExtension]
///
/// ```dart
/// class ComponentTreeConnector extends DevToolsConnector {
///   @override
///   void init() {
///     // Get the component tree of the game.
///     registerExtension(
///       'ext.flame_devtools.getComponentTree',
///       (method, parameters) async {
///         final componentTree = ComponentTreeNode.fromComponent(game);
///
///         return ServiceExtensionResponse.result(
///           json.encode({
///             'component_tree': componentTree.toJson(),
///           }),
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// # DevTools 中调用扩展. [ServiceManager.callServiceExtensionOnMainIsolate]
///
/// ```dart
/// static Future<ComponentTreeNode> getComponentTree() async {
///   final componentTreeResponse = await serviceManager
///       .callServiceExtensionOnMainIsolate(
///         'ext.flame_devtools.getComponentTree',
///       );
///   return ComponentTreeNode.fromJson(
///     componentTreeResponse.json!['component_tree'] as Map<String, dynamic>,
///   );
/// }
/// ```
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
      child: RoundedOutlinedBorder(
        // Shared component
        child: Column(
          children: [
            AreaPaneHeader(
              // Shared component
              roundedTopBorder: false,
              includeTopBorder: false,
              title: Text('[angcyo]This is a section header'),
            ),
            Expanded(
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
                  return Center(
                    child: Text(
                      dtdManager.uri?.toString() ??
                          serviceManager.connectedApp?.operatingSystem ??
                          serviceManager.connectedApp?.flutterVersionNow
                              ?.toString() ??
                          serviceManager.connectedApp?.toString() ??
                          "!angcyo devtools!",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
