part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/25
///
/// 文件列表浏览界面, 返回选中的文件路径
/// [_DebugFilePageState._handleResult]
class DebugFilePage extends StatefulWidget {
  /// 初始化的路径, 不指定则使用默认的
  final String? initPath;

  /// 选中的文件是否显示保存
  /// - [isDesktopOrWeb]
  @defInjectMark
  final bool? isSaveSelectedPath;

  const DebugFilePage({super.key, this.initPath, this.isSaveSelectedPath});

  @override
  State<DebugFilePage> createState() => _DebugFilePageState();
}

class _DebugFilePageState extends State<DebugFilePage>
    with AbsScrollPage, DebugFileListStateMixin {
  final ScrollController _pathScrollController = ScrollController();

  /// 是否保存选中的文件路径
  bool get isSaveSelectedPath => widget.isSaveSelectedPath ?? isDesktopOrWeb;

  @override
  PreferredSizeWidget? buildAppBar(
    BuildContext context, {
    bool? useSliverAppBar,
    Widget? title,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool? centerTitle,
    bool? automaticallyImplyLeading,
    Widget? leading,
    Widget? dismissal,
    Widget? trailing,
    PreferredSizeWidget? bottom,
    List<Widget>? actions,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: [
        loadCoreAssetSvgPicture(
              Assets.svg.fileBrowseHome,
              width: 25,
              height: 25,
              tintColor: context.isThemeDark
                  ? globalTheme.textTitleStyle.color
                  : null,
            )
            ?.paddingAll(kX)
            .inkWellCircle(() {
              _reload();
            })
            .tooltip(widget.initPath),
        currentLoadFolderPath
            ?.text(style: globalTheme.textTitleStyle)
            .scroll(
              scrollDirection: Axis.horizontal,
              controller: _pathScrollController,
            )
            .padding(0, kX, kX, kX)
            .ink(() {
              loadPathMixin(currentLoadFolderPath?.parentPath);
            })
            .tooltip(currentLoadFolderPath)
            .expanded(),
        GradientButton.min(
          onTap: _handleResult,
          enable: selectFilePath != null,
          padding: const EdgeInsets.symmetric(horizontal: kX, vertical: kL),
          child:
              (isSaveSelectedPath
                      ? (LibRes.maybeOf(context)?.libSave ?? "保存")
                      : (LibRes.maybeOf(context)?.libConfirm ?? "确定"))
                  .text(),
        ).insets(h: kH),
      ].row()!.safeArea(),
    );
  }

  /// 选中文件并返回路由
  void _handleResult() {
    if (isSaveSelectedPath) {
      saveFilePath(selectFilePath, context, null);
    } else {
      context.navigatorMaybeOf()?.pop(selectFilePath);
    }
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void reassemble() {
    super.reassemble();
    loadPathMixin(currentLoadFolderPath ?? widget.initPath);
  }

  /// 重新加载
  void _reload() {
    if (widget.initPath == null) {
      fileDirectory().getValue((value, error) {
        //l.d(value);
        loadPathMixin(value?.path);
        postCallback(() {
          _pathScrollController.scrollToBottom();
        });
      });
    } else {
      loadPathMixin(widget.initPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _buildPathWidget(context, currentLoadFolderPath);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
      return _buildPathWidget(context, beforeLoadFolderPath);
    }
  }

  Widget _buildPathWidget(BuildContext context, String? path) {
    final globalConfig = GlobalConfig.of(context);
    return buildScaffold(
      context,
      children: [
        if (loadError != null)
          globalConfig
              .errorPlaceholderBuilder(context, loadError)
              .align(Alignment.center)
              .sliverExpand(),
        if (loadFileList == null)
          globalConfig
              .loadingIndicatorBuilder(context, this, null, null)
              .align(Alignment.center)
              .sliverExpand(),
        if (loadFileList?.isEmpty == true)
          globalConfig
              .emptyPlaceholderBuilder(
                context,
                LibRes.maybeOf(context)?.libAdapterNoData ?? "暂无数据",
              )
              .align(Alignment.center)
              .sliverExpand(),
        ...buildFileListWidget(context),
      ],
    );
  }

  @override
  void onSelfLoadPath(String? path) {
    _pathScrollController.scrollToBottom();
    super.onSelfLoadPath(path);
  }
}
