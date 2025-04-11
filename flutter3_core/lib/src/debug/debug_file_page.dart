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

  const DebugFilePage({super.key, this.initPath});

  @override
  State<DebugFilePage> createState() => _DebugFilePageState();
}

class _DebugFilePageState extends State<DebugFilePage> with AbsScrollPage {
  final ScrollController _pathScrollController = ScrollController();

  /// 当前加载的路径
  String? currentLoadPath;

  /// 选中的文件路径
  String? _selectPath;

  /// 加载出来的文件列表, 如果为null, 则表示正在加载中
  List<FileSystemEntity>? _fileList;

  /// 加载出错时的数据
  dynamic _error;

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
          tintColor:
              context.isThemeDark ? globalTheme.textTitleStyle.color : null,
        )?.paddingAll(kX).inkWellCircle(() {
          _reload();
        }),
        currentLoadPath
            ?.text(style: globalTheme.textTitleStyle)
            .scroll(
                scrollDirection: Axis.horizontal,
                controller: _pathScrollController)
            .padding(0, kX, kX, kX)
            .ink(() {
          _loadPath(currentLoadPath?.parentPath);
        }).expanded(),
        GradientButton.min(
            onTap: _handleResult,
            enable: _selectPath != null,
            padding: const EdgeInsets.symmetric(horizontal: kX, vertical: kL),
            child: LibRes.of(context).libConfirm.text()),
        Empty.width(kX),
      ].row()!.safeArea(),
    );
  }

  /// 选中文件并返回路由
  void _handleResult() {
    Navigator.of(context).pop(_selectPath);
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadPath(currentLoadPath ?? widget.initPath);
  }

  /// 重新加载
  void _reload() {
    if (widget.initPath == null) {
      fileDirectory().getValue((value, error) {
        //l.d(value);
        _loadPath(value?.path);
        postCallback(() {
          _pathScrollController.scrollToBottom();
        });
      });
    } else {
      _loadPath(widget.initPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _buildPathWidget(context, currentLoadPath);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
      return _buildPathWidget(context, _beforePath);
    }
  }

  Widget _buildPathWidget(BuildContext context, String? path) {
    final globalConfig = GlobalConfig.of(context);
    return buildScaffold(context, children: [
      if (_error != null)
        globalConfig
            .errorPlaceholderBuilder(context, _error)
            .align(Alignment.center)
            .sliverExpand(),
      if (_fileList == null)
        globalConfig
            .loadingIndicatorBuilder(context, this, null)
            .align(Alignment.center)
            .sliverExpand(),
      if (_fileList?.isEmpty == true)
        globalConfig
            .emptyPlaceholderBuilder(
                context, LibRes.of(context).libAdapterNoData)
            .align(Alignment.center)
            .sliverExpand(),
      if (_fileList != null)
        for (var path in _fileList!)
          DebugFileTile(
            path: path.path,
            onTap: _loadPath,
            isSelected: path.path == _selectPath,
            onDeleteAction: () {
              _loadPath(currentLoadPath);
            },
          ),
    ]);
  }

  String? _beforePath;

  /// 加载指定路径
  void _loadPath(String? path) {
    assert(() {
      l.d('准备加载路径:$path');
      return true;
    }());
    if (path?.isFileSync() == true) {
      _selectPath = path;
      updateState();
      return;
    }

    _error = null;
    _fileList = null;
    _beforePath = currentLoadPath;
    currentLoadPath = path;
    _pathScrollController.scrollToBottom();
    updateState();

    /*compute<String?, List<FileSystemEntity>?>(
            (message) => message?.folder.listFilesSync(), path)
        .getValue((value, error) {
      _fileList = value;
      updateState();
    });*/

    io(path, (message) => message?.folder.listFilesSync(throwError: true))
        .getValue((value, error) {
      assert(() {
        l.d('加载->$value $error');
        return true;
      }());
      _fileList = value;
      _error = error;
      updateState();
    });
  }
}
