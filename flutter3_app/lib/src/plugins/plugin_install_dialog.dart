part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/11
///
/// [PluginMixin]插件安装/更新弹窗
///
/// - [PluginMixin] 安装插件的小部件
/// 目前就是下载插件, 并解压到本地
class PluginInstallDialog extends StatefulWidget with DialogMixin {
  @override
  TranslationType get translationType => .scaleFade;

  /// 需要安装的插件
  final PluginMixin plugin;

  /// 插件当前的状态
  final PluginState? pluginState;

  const PluginInstallDialog(this.plugin, {super.key, this.pluginState});

  @override
  State<PluginInstallDialog> createState() => _PluginInstallDialogState();
}

class _PluginInstallDialogState extends State<PluginInstallDialog>
    with DioDownloadMixin {
  /// 插件的状态
  PluginState pluginState = PluginState.uninstall;

  @override
  void initState() {
    if (widget.pluginState != null) {
      pluginState = widget.pluginState!;
    }
    super.initState();
  }

  @override
  void dispose() {
    downloadTokenMixin?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //debugger();
    return widget
        .buildAdaptiveCenterDialog(
          context,
          pluginState == .uninstall
              ? buildInstallContent(context, globalTheme)
              : pluginState == .update
              ? buildUpdateContent(context, globalTheme)
              : pluginState == .downloading
              ? buildDownloadingContent(context, globalTheme)
              : pluginState == .installing
              ? buildInstallingContent(context, globalTheme)
              : empty,
          autoCloseDialog: false,
        )
        .interceptPopResult(() {
          if (pluginState == .installed) {
            widget.closeDialogIf(context);
          }
        });
  }

  // MARK: - build

  /// 构建安装提示小部件
  @property
  Widget buildInstallContent(BuildContext context, GlobalTheme globalTheme) {
    return [
      "插件未安装, 是否下载安装"
          .text(textStyle: globalTheme.textTitleStyle)
          .insets(all: kX, bottom: kXx),
      [
        GradientButton.stroke(
          child: "取消".text(),
          onTap: () {
            widget.closeDialogIf(context);
          },
        ).expanded(),
        GradientButton(
          child: "安装".text(),
          onTap: () {
            final url = widget.plugin.downloadUrl;
            if (url != null) {
              pluginState = .downloading;
              l.i("[${classHash()}]准备下载插件->$url");
              startDownloadMixin(url);
              updateState();
            }
          },
        ).expanded(),
      ].row(gap: kX),
    ].column()!.insets(all: kX);
  }

  /// 构建更新提示小部件
  @property
  Widget buildUpdateContent(BuildContext context, GlobalTheme globalTheme) {
    return [
      "发现新版本插件, 是否更新"
          .text(textStyle: globalTheme.textTitleStyle)
          .insets(all: kX, bottom: kXx),
      [
        GradientButton.stroke(
          child: "取消".text(),
          onTap: () {
            //取消更新, 则直接运行
            widget.closeDialogIf(context);
            widget.plugin.start(buildContext, ignoreUpdate: true);
          },
        ).expanded(),
        GradientButton(
          child: "更新".text(),
          onTap: () {
            final url = widget.plugin.downloadUrl;
            if (url != null) {
              pluginState = .downloading;
              l.i("[${classHash()}]准备更新下载插件->$url");
              startDownloadMixin(url);
              updateState();
            }
          },
        ).expanded(),
      ].row(gap: kX),
    ].column()!.insets(all: kX);
  }

  /// 构建下载中小部件
  @property
  Widget buildDownloadingContent(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return [
      "插件下载中...${(downloadProgressMixin * 100).round()}%"
          .text(textStyle: globalTheme.textTitleStyle)
          .insets(all: kX, bottom: kXx),
      buildProgressWidget(context),
      [
        GradientButton.stroke(
          child: "取消".text(),
          onTap: () {
            widget.closeDialogIf(context);
          },
        ).expanded(),
      ].row(gap: kX),
    ].column()!.insets(all: kX);
  }

  /// 构建安装中小部件
  @property
  Widget buildInstallingContent(BuildContext context, GlobalTheme globalTheme) {
    return [
      "插件安载中...".text(textStyle: globalTheme.textTitleStyle).insets(all: kXx),
    ].column()!.insets(all: kX);
  }

  /// 下载成功, 开始安装插件
  @override
  void onDownloadSuccess(String filePath) async {
    pluginState = .installing;
    updateState();
    final result = await widget.plugin.install(filePath);
    if (result) {
      widget.closeDialogIf(context);
      widget.plugin.start(buildContext);
    } else {
      debugger();
      widget.closeDialogIf(context);
      toast("插件安装失败".text(useDefStyle: false));
    }
  }
}
