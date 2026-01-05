part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/28
///
/// 提供一个等待被打开的文件域
/// - 比如拖拽过来等待打开的文件
/// - 粘贴过来等待打开的文件
/// - 菜单打开的文件
/// - ...

/// 等待被打开的数据
class OpenFileScopeData {
  /// Uri
  final List<Uri>? uriList;

  /// 图片
  final List<UiImage>? imageList;

  /// 字符串
  final List<String>? textList;

  const OpenFileScopeData({this.uriList, this.imageList, this.textList});
}

/// 提供[OpenFileScopeData]的小部件
class OpenFileScope extends InheritedWidget {
  /// 获取需要打开的数据
  @api
  static UpdateValueNotifier<OpenFileScopeData?>? get(
    BuildContext? context, {
    bool depend = false,
  }) {
    if (depend) {
      return context?.dependOnInheritedWidgetOfExactType<OpenFileScope>()?.data;
    } else {
      return context?.getInheritedWidgetOfExactType<OpenFileScope>()?.data;
    }
  }

  //MARK:  - scope

  /// 需要打开的数据, 请在处理之后主动清空
  final UpdateValueNotifier<OpenFileScopeData?>? data;

  const OpenFileScope({super.key, required this.data, required super.child});

  @override
  bool updateShouldNotify(covariant OpenFileScope oldWidget) =>
      data?.value != oldWidget.data?.value;
}

//MARK: - ex
extension OpenFileScopeEx on Widget {
  /// 提供一个需要打开的数据[OpenFileScopeData]
  /// - 监听这个值, 并且处理对应的数据
  Widget provideOpenFileData(
    UpdateValueNotifier<OpenFileScopeData?>? data, {
    Key? key,
  }) => OpenFileScope(data: data, key: key, child: this);
}

//MARK: - open mixin

/// 混入操作, 自动处理[OpenFileScope.data]中的数据
mixin OpenFileScopeStateMixin<T extends StatefulWidget> on State<T> {
  /// 需要监听的数据
  UpdateValueNotifier<OpenFileScopeData?>? openFileDataMixin;

  /// 当前终端是否是最后一个处理器
  bool get isLastOpenFileHandler =>
      openFileDataMixin?.lastListener == handleOpenFileDataMixin;

  @override
  void initState() {
    super.initState();
    openFileDataMixin = OpenFileScope.get(buildContext);
    openFileDataMixin?.addListener(handleOpenFileDataMixin);
  }

  @override
  void dispose() {
    openFileDataMixin?.removeListener(handleOpenFileDataMixin);
    super.dispose();
  }

  /// 处理完数据之后, 请主动清空数据
  @callPoint
  void handleOpenFileDataMixin() {
    final data = openFileDataMixin?.value;
    if (data != null) {
      onHandleOpenFileDataMixin(data).get((data, error) {
        if (data == true) {
          clearOpenFileDataMixin();
          return;
        } else {
          assert(() {
            l.w("[${classHash()}]未处理的数据[$data]->$error");
            return true;
          }());
        }
      });
    }
  }

  ///@return 返回true 表示处理了数据
  @overridePoint
  Future<bool> onHandleOpenFileDataMixin(OpenFileScopeData data) async {
    return false;
  }

  /// 清空数据
  @api
  void clearOpenFileDataMixin() {
    openFileDataMixin?.value = null;
  }
}
