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

  /// 是否是debug模式
  final bool? debug;

  const AppAboutDialog({super.key, this.logo, this.debug});

  @override
  State<AppAboutDialog> createState() => _AppAboutDialogState();
}

class _AppAboutDialogState extends State<AppAboutDialog> {
  @override
  void initState() {
    super.initState();
    $platformDeviceInfoCache;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return $platformPackageInfo
        .toWidget((ctx, info) {
          return widget.buildAdaptiveCenterDialog(
            context,
            [
              //MARK: - main
              (widget.logo ??
                      AppPackageAssetsWidget(
                        appKey: "assets/png/logo.png",
                        size: 64,
                        emptyWidget: FlutterLogo(size: 64),
                      ))
                  .tooltip($platformDeviceName),
              "${info?.appName}".text(style: globalTheme.tileTextTitleStyle),
              ("${"Version".connect($buildFlavor == null ? "" : "(${$buildFlavor})")}: ${info?.version}(${info?.buildNumber})"
                      .connect($buildType == null ? "" : "(${$buildType})"))
                  .text(style: globalTheme.textDesStyle)
                  .insets(vertical: kX)
                  .click(() {
                    showLoading();
                    LibAppVersionBean.fetchConfig(
                      LibAppVersionBean.appVersionUrl,
                      checkUpdate: true,
                      forceShow: null,
                      forceForbiddenShow: null,
                      onUpdateAction: (update) {
                        hideLoading();
                        if (!update) {
                          toast("已是最新版本".text());
                        }
                      },
                      /*debugLabel: "test",*/
                    );
                  }),
              "${info?.packageName}".text(style: globalTheme.textDesStyle),
              //MARK: - debug
              if (widget.debug ?? isDebugFlag)
                [
                  $platformDeviceInfoCache
                      ?.toString()
                      .text(
                        style: globalTheme.textDesStyle,
                        selectable: true,
                        textAlign: .center,
                      )
                      .insets(all: kX),
                  DebugPage.buildDebugLastWidget(context, globalTheme),
                ].scrollVertical()?.expanded(),
            ].column()!.insets(vertical: kXh),
            autoCloseDialog: true,
            showCloseButton: true,
          );
        })
        .ignoreKeyEvent(tag: classHash());
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
