part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/20
///
/// # flutter_install_app: ^1.3.0
///
/// ```
/// /// App Info
/// String androidAppId = 'com.felipheallef.tasks';
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
class AppUpdateDialog extends StatefulWidget with DialogMixin {
  /// 检查更新并且显示
  /// [forceShow] 是否强制显示更新, 不检查版本号
  @api
  static void checkUpdateAndShow(
    BuildContext? context,
    AppVersionBean bean, {
    bool? forceShow,
  }) async {
    if (context == null || context.isMounted != true) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return;
    }

    //1: 平台检查, 获取对应平台的版本信息
    final AppVersionBean platformBean =
        bean.platformMap?[$platformName] ?? bean;

    //2: 区分package, 获取对应报名的版本信息
    final AppVersionBean packageBean =
        platformBean.packageNameMap?[$appPackageName] ?? platformBean;

    //3: 获取指定设备的版本信息
    final AppVersionBean deviceBean =
        packageBean.versionUuidMap?[$coreKeys.deviceUuid] ?? packageBean;

    //end
    final AppVersionBean versionBean = deviceBean;

    //check
    final localVersionCode = (await appVersionCode).toIntOrNull() ?? 0;
    //debugger();
    if (versionBean.debug != true ||
        (versionBean.debug == true && isDebugFlag)) {
      //forbidden检查
      final forbiddenVersionMap = versionBean.forbiddenVersionMap;
      final forbiddenBean = forbiddenVersionMap
              ?.find((key, value) => key.matchVersion(localVersionCode))
              ?.value ??
          versionBean;
      if (forbiddenBean.forbiddenReason != null) {
        GlobalConfig.def.findNavigatorState()?.showWidgetDialog(MessageDialog(
              title: forbiddenBean.forbiddenTile,
              message: forbiddenBean.forbiddenReason,
              confirm: forbiddenBean.forceForbidden == true
                  ? null
                  : LibRes.of(context).libConfirm,
              interceptPop: forbiddenBean.forceForbidden == true,
            ));
      }

      //更新检查
      final versionCode = versionBean.versionCode ?? 0;
      if (forceShow == true || versionCode > localVersionCode) {
        //需要更新
        context.showWidgetDialog(AppUpdateDialog(versionBean));
      }
    }
  }

  @override
  TranslationType get translationType => TranslationType.scaleFade;

  /// 信息
  final AppVersionBean versionBean;

  final double headerMarginTop;
  final double headerPaddingTop;

  const AppUpdateDialog(
    this.versionBean, {
    super.key,
    this.headerMarginTop = 22,
    this.headerPaddingTop = 60,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  @override
  void dispose() {
    _downloadToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    //控制按钮
    Widget control = [
      if (widget.versionBean.forceUpdate != true)
        GradientButton(
                onTap: () {
                  context.pop();
                },
                color: globalTheme.whiteSubBgColor,
                radius: kMaxBorderRadius,
                child: "下次再说".text(
                    style: globalTheme.textGeneralStyle,
                    fontWeight: FontWeight.bold))
            .expanded(),
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
                child: "前往下载".text(
                    style: globalTheme.textGeneralStyle,
                    fontWeight: FontWeight.bold))
            .expanded()
      else
        GradientButton(
                onTap: () {
                  switch (_downloadState) {
                    case DownloadState.none:
                      _startDownload(widget.versionBean.downloadUrl ?? "");
                      break;
                    case DownloadState.downloading:
                      break;
                    case DownloadState.downloaded:
                      //安装apk
                      _startInstallApk();
                      break;
                    case DownloadState.downloadFailed:
                      _startDownload(widget.versionBean.downloadUrl ?? "");
                      break;
                    default:
                      break;
                  }
                },
                radius: kMaxBorderRadius,
                child: (_downloadState == DownloadState.none
                        ? "立即下载"
                        : (_downloadState == DownloadState.downloading
                            ? "下载中..."
                            : (_downloadState == DownloadState.downloaded
                                ? "立即安装"
                                : (_downloadState ==
                                        DownloadState.downloadFailed
                                    ? "点击重试"
                                    : "Unknown"))))
                    .text(
                        style: globalTheme.textGeneralStyle,
                        fontWeight: FontWeight.bold))
            .expanded(),
    ].row(gap: kX)!;

    //内容
    Widget content = [
      Empty.height(widget.headerPaddingTop),
      "V${widget.versionBean.versionName ?? ""}".text(
        style: globalTheme.textGeneralStyle,
        fontWeight: FontWeight.bold,
      ),
      //widget.versionBean.versionDes?.toMarkdownWidget(context)
      widget.versionBean.versionDes
          ?.text(style: globalTheme.textBodyStyle)
          .scroll()
          .constrainedMax(minWidth: double.infinity, maxHeight: 200)
          .paddingSymmetric(vertical: kX),
      _buildProgress(),
      control
    ].column(
      crossAxisAlignment: CrossAxisAlignment.start,
    )!;

    //头部
    Widget header = [
      AppPackageAssetsSvgWidget(
        resKey: Assets.svg.appUpdateHeader,
        libPackage: Assets.package,
      ).position(left: 0, right: 0),
      widget.versionBean.versionTile
          ?.text(
            style: globalTheme.textBigGeneralStyle,
            fontWeight: FontWeight.bold,
          )
          .position(left: kX, bottom: 0)
    ].stack()!.size(height: widget.headerMarginTop + widget.headerPaddingTop);

    //body
    Widget body = widget.buildCenterDialog(
      context,
      [
        content.container(
          color: globalTheme.whiteBgColor,
          margin: EdgeInsets.only(top: widget.headerMarginTop),
          padding: widget.contentPadding,
          radius: kDefaultBorderRadiusXX,
        ),
        header,
      ].stack()!,
      padding: EdgeInsets.zero,
      decorationColor: Colors.transparent,
    );

    return body.interceptPopResult(() {
      if (widget.versionBean.forceUpdate == true) {
        //强制更新, 不允许关闭
      } else {
        buildContext?.pop();
      }
    });
  }

  /// 构建下载进度小部件
  Widget? _buildProgress() {
    double progress = _downloadProgress;
    if (_downloadState == DownloadState.none) {
      return null;
    }
    //debugger();
    return ProgressBar(
      progress: progress == -1 ? 1 : progress,
      enableFlowProgressAnimate: _downloadState == DownloadState.downloading,
    ).size(height: 6).paddingSymmetric(vertical: kL);
  }

  /// 下载的状态
  DownloadState _downloadState = DownloadState.none;

  /// 用来取消下载
  CancelToken? _downloadToken;

  /// 下载进度[0~1]
  double _downloadProgress = 0;

  String _downloadFilePathCache = "";

  /// 开始下载
  /// `/storage/emulated/0/Android/data/com.angcyo.flutter3.abc/cache/AutoCalibrate-2.4.0_apk_release_app.apk`
  void _startDownload(String url) async {
    _downloadToken?.cancel();
    _downloadToken = CancelToken();

    _downloadProgress = -1;
    _downloadState = DownloadState.downloading;
    final name = url.fileName();
    final filePath = await cacheFilePath(name);
    _downloadFilePathCache = filePath;
    url
        .download(
            savePath: filePath,
            cancelToken: _downloadToken,
            onReceiveProgress: (count, total) {
              if (total > 0) {
                //l.d("下载进度:$count/$total ${count.toSizeStr()}/${total.toSizeStr()} ${(count / total * 100).toDigits(digits: 2)}% \n[$url]->[$filePath]");
                _downloadProgress = count / total;
                updateState();
              } else {
                //l.d("下载进度:$count ${count.toSizeStr()} \n[$url]->[$filePath]");
                _downloadProgress = -1;
              }
            })
        .get((response, error) {
      if (response != null) {
        _downloadState = DownloadState.downloaded;
        updateState();
        _startInstallApk();
        //l.d("下载完成:$filePath");
      } else if (error != null) {
        if (_downloadProgress == -1) {
          _downloadProgress = 0;
        }
        _downloadState = DownloadState.downloadFailed;
        updateState();
      }
    });
  }

  /// iOS 平台无法安装APK
  void _startInstallApk() {
    AppInstaller.installApk(_downloadFilePathCache);
  }
}
