import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_android_package_installer/flutter_android_package_installer.dart';

import '../../assets_generated/assets.gen.dart';
import '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/20
///
/// # flutter_install_app: ^1.3.0
///
/// ```
/// /// App Info
/// String androidAppId = 'com.angcyo.tasks';
/// String iOSAppId = '324684580';
///
/// AppInstaller.goStore(androidAppId, iOSAppId);
/// ```
///
/// ```
/// AppInstaller.goStore(androidAppId, iOSAppId, review: true);
/// ```
///
/// 应用程序更新提示弹窗
///
/// - [AppUpdateDialog]
/// - [AppUpdateLogDialog]
/// - [AppUpdateLogListScreen]
///
/// - [AppUpdateDialog.checkUpdateAndShow] 检测更新并显示[LibAppVersionBean]
///
class AppUpdateDialog extends StatefulWidget with DialogMixin {
  /// 检查更新并且显示
  /// [forceShow] 是否强制显示更新, 不检查版本号
  /// 在[AppVersionBean.fetchConfig]中触发
  ///
  /// @return 是否有新版本
  @api
  static Future<bool> checkUpdateAndShow(
    BuildContext? context,
    LibAppVersionBean bean, {
    bool? forceShow,
    bool? forceForbiddenShow,
    String? debugLabel,
  }) async {
    debugger(when: debugLabel != null);
    NavigatorState? navigator;
    LibRes? libRes;
    if (context == null || context.isMounted != true) {
    } else {
      navigator = context.navigatorOf(true);
      libRes = LibRes.of(context);
    }

    final deviceUuid = $coreKeys.deviceUuid;
    final LibAppVersionBean versionBean = bean.it;
    bool ignoreDeviceUpdate = false; //是否要忽略当前设备的更新

    final allowVersionUuidList = versionBean.allowVersionUuidList;
    if (allowVersionUuidList != null) {
      if (allowVersionUuidList.size() > 0) {
        if (!allowVersionUuidList.contains(deviceUuid)) {
          //当前设备不在白名单中
          ignoreDeviceUpdate = true;
        }
      }
    }

    if (!ignoreDeviceUpdate) {
      final denyVersionUuidList = versionBean.denyVersionUuidList;
      if (denyVersionUuidList != null) {
        if (denyVersionUuidList.contains(deviceUuid)) {
          //当前设备在黑名单中
          ignoreDeviceUpdate = true;
        }
      }
    }

    //check
    final localVersionCode = (await $appVersionCode).toIntOrNull() ?? 0;
    //debugger();
    if (forceForbiddenShow == true ||
        versionBean.debug != true ||
        (versionBean.debug == true && isDebugFlag)) {
      //forbidden检查
      final forbiddenVersionMap = versionBean.forbiddenVersionMap;
      final forbiddenBean =
          forbiddenVersionMap
              ?.find((key, value) => key.matchVersion(localVersionCode))
              ?.value ??
          versionBean;
      if (forceForbiddenShow == true || forbiddenBean.forbiddenReason != null) {
        final forceForbidden = forbiddenBean.forceForbidden == true;
        (GlobalConfig.def.findNavigatorState() ?? navigator)?.showWidgetDialog(
          MessageDialog(
            title: forbiddenBean.forbiddenTile,
            message: forbiddenBean.forbiddenReason ?? "（o´ﾟ□ﾟ`o）",
            confirm: libRes?.libKnown,
            showConfirm: !forceForbidden,
            interceptPop: forceForbidden,
            dialogBarrierDismissible: !forceForbidden,
          ).click(() {
            exitApp();
          }, enable: forceForbidden).ignoreKeyEvent(),
        );
      }

      //更新检查
      if (!ignoreDeviceUpdate) {
        final versionCode = versionBean.versionCode ?? 0;
        if (forceShow == true || versionCode > localVersionCode) {
          //需要更新
          assert(() {
            l.i(
              "需要更新->forceShow:${forceShow?.toDC()} versionCode:$versionCode localVersionCode:$localVersionCode",
            );
            return true;
          }());
          navigator?.showWidgetDialog(
            AppUpdateDialog(versionBean, forceUpdate: null),
          );
          return true;
        }
      }
    }
    return false;
  }

  @override
  TranslationType get translationType => TranslationType.scaleFade;

  /// 信息
  final LibAppVersionBean versionBean;

  /// 是否强制更新
  final bool? forceUpdate;

  final double headerMarginTop;
  final double headerPaddingTop;

  const AppUpdateDialog(
    this.versionBean, {
    super.key,
    this.forceUpdate,
    this.headerMarginTop = 22,
    this.headerPaddingTop = 60,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog>
    with DioDownloadMixin {
  @override
  void dispose() {
    downloadTokenMixin?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final lRes = libRes(context);
    final forceUpdate =
        widget.forceUpdate == true || widget.versionBean.forceUpdate == true;

    //控制按钮
    Widget control = [
      if (forceUpdate != true)
        GradientButton(
          onTap: () {
            context.pop();
          },
          color: globalTheme.whiteSubBgColor,
          radius: kMaxBorderRadius,
          child: lRes?.libNextTime.text(
            style: globalTheme.textGeneralStyle,
            fontWeight: FontWeight.bold,
          ),
        ).expanded(),
      if (widget.versionBean.jumpToMarket == true ||
          widget.versionBean.outLink == true)
        GradientButton(
          onTap: () {
            if (widget.versionBean.jumpToMarket == true) {
              widget.versionBean.marketUrl?.launch();
            } else if (widget.versionBean.outLink == true) {
              widget.versionBean.downloadUrl?.launch();
            }
          },
          radius: kMaxBorderRadius,
          child: lRes?.libGoDownload.text(
            style: globalTheme.textGeneralStyle,
            fontWeight: FontWeight.bold,
          ),
        ).expanded()
      else
        GradientButton(
          onTap: () {
            switch (downloadStateMixin) {
              case DownloadState.none:
                startDownloadMixin(widget.versionBean.downloadUrl ?? "");
                break;
              case DownloadState.downloading:
                break;
              case DownloadState.downloaded:
                //安装apk
                _startInstallApk();
                break;
              case DownloadState.downloadFailed:
                startDownloadMixin(widget.versionBean.downloadUrl ?? "");
                break;
              default:
                break;
            }
          },
          radius: kMaxBorderRadius,
          child:
              (downloadStateMixin == DownloadState.none
                      ? lRes?.libDownloadNow
                      : (downloadStateMixin == DownloadState.downloading
                            ? lRes?.libDownloading
                            : (downloadStateMixin == DownloadState.downloaded
                                  ? lRes?.libInstallNow
                                  : (downloadStateMixin ==
                                            DownloadState.downloadFailed
                                        ? lRes?.libClickRetry
                                        : "Unknown"))))
                  ?.text(
                    style: globalTheme.textGeneralStyle,
                    fontWeight: FontWeight.bold,
                  ),
        ).expanded(),
    ].row(gap: kX)!;

    //内容
    Widget content = [
      Empty.height(widget.headerPaddingTop),
      widget.versionBean.versionName
          ?.connect(
            null,
            widget.versionBean.versionName?.toLowerCase().startsWith("v") ==
                    true
                ? null
                : "v",
          )
          .text(
            style: globalTheme.textGeneralStyle,
            fontWeight: FontWeight.bold,
          ),
      //widget.versionBean.versionDes?.toMarkdownWidget(context)
      widget.versionBean.versionDes
          ?.text(style: globalTheme.textBodyStyle)
          .scroll()
          .constrainedMax(
            minWidth: 300 /*$screenWidth / 3*/ /*double.infinity*/,
            maxHeight: $screenHeight / 3,
          )
          .insets(vertical: kX)
          .expanded(),
      buildProgressWidget(context),
      control,
    ].column(crossAxisAlignment: CrossAxisAlignment.start)!.ih();

    //头部
    Widget header = [
      AppPackageAssetsWidget(
        resKey: Assets.svg.appUpdateHeader,
        libPackage: Assets.package,
      ).position(left: 0, right: 0),
      (widget.versionBean.versionTile ?? lRes?.libNewReleases)
          ?.text(
            style: globalTheme.textGeneralStyle.copyWith(fontSize: 22),
            fontWeight: FontWeight.bold,
          )
          .position(left: kX, bottom: 0),
    ].stack()!.size(height: widget.headerMarginTop + widget.headerPaddingTop);

    //body
    Widget body = widget.buildCenterDialog(
      context,
      [
        content.container(
          color: globalTheme.whiteBgColor,
          margin: EdgeInsets.only(top: widget.headerMarginTop),
          padding: widget.dialogContentPadding,
          radius: kDefaultBorderRadiusXX,
        ),
        header,
      ].stack()!,
      padding: EdgeInsets.zero,
      decorationColor: Colors.transparent,
      /*autoCloseDialog: true,*/
    );
    return body
        .interceptPopResult(() {
          //debugger();
          if (forceUpdate) {
            //强制更新, 不允许关闭
          } else {
            buildContext?.pop(rootNavigator: widget.dialogUseRootNavigator);
          }
        })
        .focusScope(tag: classHash());
  }

  /// iOS 平台无法安装APK
  void _startInstallApk() {
    //debugger();
    AndroidPackageInstaller.installApk(apkFilePath: downloadFilePathCacheMixin);
  }
}

/// 更新日志弹窗
/// - [AppUpdateLogDialog]
/// - [AppUpdateLogListScreen]
class AppUpdateLogDialog extends StatelessWidget with DialogMixin {
  /// 当前的数据
  final LibAppVersionBean bean;

  /// 查看更多时的数据
  final List<LibAppVersionBean>? beanList;

  /// 不指定[beanList]时, 可以单独设置查看更多回调
  final VoidAction? onClickMoreAction;

  @override
  TranslationType get translationType => TranslationType.scaleFade;

  const AppUpdateLogDialog({
    super.key,
    required this.bean,
    this.beanList,
    this.onClickMoreAction,
  });

  /// 是否显示查看更多
  bool get showMore => beanList != null || onClickMoreAction != null;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final lRes = libRes(context);

    //内容
    final content = [
      (bean.versionTile ?? "${bean.versionName} 更新说明:")
          .text(style: globalTheme.textTitleStyle, bold: true)
          .paddingOnly(horizontal: kX, top: kX * 2),
      bean.versionDes
          ?.text()
          .scroll()
          .constrainedMax(
            minWidth: double.infinity,
            maxHeight: $screenHeight / 3,
          )
          .insets(vertical: kX)
          .expanded(),
      hLine(context),
      if (showMore)
        "查看更多"
            .text(textAlign: TextAlign.center)
            .center()
            .constrainedMin(minHeight: kButtonHeight)
            .matchParentWidth()
            .inkWell(() {
              context.popDialog();
              if (onClickMoreAction == null) {
                context.pushWidget(AppUpdateLogListScreen(beanList: beanList));
              } else {
                onClickMoreAction?.call();
              }
            }),
      if (showMore) hLine(context),
      "确定"
          .text(textAlign: TextAlign.center, textColor: globalTheme.accentColor)
          .center()
          .constrainedMin(minHeight: kButtonHeight)
          .matchParentWidth()
          .inkWell(() {
            context.popDialog();
          }),
    ].column(crossAxisAlignment: CrossAxisAlignment.start)!.material();

    //头部
    final marginTop = 100.0;
    Widget header = [
      SizedBox()
          .backgroundColor(
            globalTheme.themeWhiteColor,
            fillRadius: kDefaultBorderRadiusXX,
          )
          .position(top: marginTop, left: 0, right: 0, bottom: 0),
      AppPackageAssetsWidget(
        resKey: Assets.svg.appUpdateLogHeader,
        libPackage: Assets.package,
        size: 200,
      ).position(left: 0, right: 0),
      content.position(top: marginTop, left: 0, right: 0, bottom: 0),
    ].stack()!;

    return buildCenterDialog(
      context,
      header,
      decorationColor: Colors.transparent,
      padding: EdgeInsets.zero,
    );
  }
}

/// 更新日志列表界面
/// - [AppUpdateLogDialog]
/// - [AppUpdateLogListScreen]
///
/// - [_AppUpdateLogTile]
class AppUpdateLogListScreen extends StatelessWidget with AbsScrollPage {
  final List<LibAppVersionBean>? beanList;

  const AppUpdateLogListScreen({super.key, required this.beanList});

  @override
  String? getTitle(BuildContext context) => "更新记录";

  @override
  WidgetList? buildScrollBody(BuildContext context) {
    return [for (final bean in beanList ?? []) _AppUpdateLogTile(bean: bean)];
  }
}

/// [AppUpdateLogListScreen]
class _AppUpdateLogTile extends StatelessWidget {
  final LibAppVersionBean bean;

  const _AppUpdateLogTile({super.key, required this.bean});

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return [
      (bean.versionTile ??
              "${bean.versionDate?.connect(bean.versionName != null ? " / ${bean.versionName}" : null)}")
          .text(style: globalTheme.textTitleStyle, bold: true)
          .paddingOnly(horizontal: kX, top: kX),
      bean.versionDes?.text().insets(vertical: kX),
      hLine(context),
    ].column(crossAxisAlignment: CrossAxisAlignment.start)!;
  }
}
