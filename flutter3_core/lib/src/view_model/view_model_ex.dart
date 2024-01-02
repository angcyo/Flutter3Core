part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// https://pub.dev/packages/jetpack
/// https://github.com/praja/jetpack

/// [ViewModel]
abstract class BaseViewModel extends ViewModel {
  @override
  void onDispose() {
    super.onDispose();
  }
}

//region ---LiveData---

MutableErrorLiveData<T?> vmData<T>([T? value]) =>
    MutableErrorLiveData<T?>(value);

MutableOnceLiveData<T?> vmDataOnce<T>([T? value]) =>
    MutableOnceLiveData<T?>(value);

extension LiveDataEx<T> on LiveData<T> {
  /// 监听当前的[LiveData]数据变化
  /// [observe]
  /// [LiveDataBuilder]
  Widget listener(
          Widget Function(
            BuildContext context,
            T liveData,
            Object? error,
          ) builder) =>
      LiveDataBuilder<T>(
        liveData: this,
        builder: (context, liveData) {
          Object? error;
          if (liveData is MutableErrorLiveData) {
            error = liveData.error;
          }
          return builder(context, liveData, error);
        },
      );
}

//endregion ---LiveData---

//region ---ViewModel---

/// [ViewModel]构建函数
typedef ViewModelCreateFn = dynamic Function();

/// 全局[ViewModel]构造函数
final _vmCreateMap = <Type, ViewModelCreateFn>{};

/// 注册全局的[ViewModel]构造器[ViewModelCreateFn]
@api
void registerGlobalViewModel<T extends ViewModel>(
    ViewModelCreateFn viewModelCreate) {
  _vmCreateMap[T] = viewModelCreate;
}

/// 注销全局的[ViewModel]构造器[ViewModelCreateFn]
@api
void unregisterGlobalViewModel<T extends ViewModel>() {
  _vmCreateMap.remove(T);
}

/// 用来创建[ViewModel]的工厂
class GlobalViewModelFactory extends ViewModelFactory {
  const GlobalViewModelFactory();

  @override
  T create<T extends ViewModel>() {
    var viewModelCreate = _vmCreateMap[T];
    if (viewModelCreate == null) {
      throw Exception(
          "Unknown ViewModel type:$T, 请调用[registerGlobalViewModel]注册:$T");
    }
    return viewModelCreate() as T;
  }
}

/// 全局的[GlobalViewModelFactory]工厂
const globalViewModelFactory = GlobalViewModelFactory();

/// 用来创建[ViewModel]的工厂
class ListViewModelFactory extends ViewModelFactory {
  final List<ViewModel> viewModelList;

  const ListViewModelFactory(this.viewModelList);

  @override
  T create<T extends ViewModel>() {
    var viewModel = viewModelList.firstWhereOrNull((element) => element is T);
    if (viewModel == null) {
      throw Exception("Unknown ViewModel type:$T");
    }
    return viewModel as T;
  }
}

/// [ViewModelScope] 用来提供[ViewModelStore]
/// [ViewModelStore] 用来存储[ViewModel]
/// [LiveDataBuilder]
/// [ViewModelProviderExtension]
/// [ViewModelProviderExtension.getViewModel]
extension ViewModelWidgetEx on Widget {
  ///
  /// 全局的[ViewModelScope], 提供一个全局的[GlobalViewModelFactory], 也提供一个全局的[ViewModelStore]
  /// [ViewModelFactoryProvider]
  /// [registerGlobalViewModel]
  Widget wrapGlobalViewModelProvider([ViewModelFactory? viewModelFactory]) {
    return ViewModelFactoryProvider(
      viewModelFactory: viewModelFactory ?? globalViewModelFactory,
      child: ViewModelScope(
        builder: (context) => this,
      ),
    );
  }

  /// 用来提供[ViewModelFactoryProvider], 里面有[ViewModelFactory]
  Widget wrapViewModelListProvider(List<ViewModel> list) {
    return ViewModelFactoryProvider(
      viewModelFactory: ListViewModelFactory(list),
      child: wrapViewModelScope(),
    );
  }

  /// 提供一个[ViewModelScope], 用来存储[ViewModelStore]
  Widget wrapViewModelScope() {
    return ViewModelScope(
      builder: (context) => this,
    );
  }
}

/// [ViewModelProviderExtension]
extension ViewModelStateEx<T extends StatefulWidget> on State<T> {
  /// [ViewModelProviderExtension.getViewModel]
  Type vm<Type extends ViewModel>({String key = ""}) =>
      context.getViewModel(key: key);
}

/// [ViewModel]
T vmGlobal<T extends ViewModel>() {
  var element = GlobalConfig.def.findWidgetsAppElement();
  return element?.getViewModel<T>() ?? globalViewModelFactory.create<T>();
}

//endregion ---ViewModel---
