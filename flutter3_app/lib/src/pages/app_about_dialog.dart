import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter3_app.dart' hide Action, ContextAction;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/01
///
/// 关于App的对话框
///
class AppAboutDialog extends StatefulWidget with DialogMixin {
  ///  logo
  ///  - [FlutterLogo]
  @autoInjectMark
  final Widget? logo;

  const AppAboutDialog({super.key, this.logo});

  @override
  State<AppAboutDialog> createState() => _AppAboutDialogState();
}

class _AppAboutDialogState extends State<AppAboutDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return $platformPackageInfo.toWidget((ctx, info) {
      return widget.buildAdaptiveCenterDialog(
        context,
        [
          widget.logo ?? FlutterLogo(size: 64),
          "${info?.appName}".text(style: globalTheme.tileTextTitleStyle),
          ("${"Version".connect($buildFlavor == null ? "" : "(${$buildFlavor})")}: ${info?.version}(${info?.buildNumber})")
              .text(style: globalTheme.textDesStyle)
              .paddingOnly(vertical: kX),
          "${info?.packageName}".text(style: globalTheme.textDesStyle),
          if (isDebugFlag) DebugPage.buildDebugLastWidget(context, globalTheme),
        ].column()!.paddingOnly(vertical: kXh),
      );
    }).ignoreKeyEvent();
  }
}

class AboutIntent extends Intent {
  const AboutIntent();
}

class AboutAction extends ContextAction<AboutIntent> {
  @override
  Object? invoke(AboutIntent intent, [BuildContext? context]) {
    return context?.showWidgetDialog(AppAboutDialog());
  }
}

extension AppAboutEx on Widget {
  /// 监听F1键, 显示帮助对话框
  @desktopFlag
  Widget wrapAboutDialog() {
    if (isDesktopOrWeb) {
      return shortcutActions([
        ShortcutAction(
          intent: const AboutIntent(),
          shortcut: SingleActivator(LogicalKeyboardKey.f1),
          action: AboutAction(),
        ),
      ]);
    }
    return this;
  }
}
