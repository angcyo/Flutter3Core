part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// https://pub.dev/packages/jetpack
/// https://github.com/praja/jetpack

//region ---LiveData---

MutableLiveData<T?> vmData<T>([T? value]) => MutableLiveData<T?>(value);

MutableOnceLiveData<T?> vmDataOnce<T>([T? value]) =>
    MutableOnceLiveData<T?>(value);

//endregion ---LiveData---

//region ---ViewModel---

/// [ViewModel]构建函数
typedef ViewModelCreate = Object Function();

/// 全局[ViewModel]构造函数
final _vmCreateMap = <Type, ViewModelCreate>{};

/// 注册全局的[ViewModel]构造器[ViewModelCreate]
void registerGlobalViewModel<T extends ViewModel>(
    ViewModelCreate viewModelCreate) {
  _vmCreateMap[T] = viewModelCreate;
}

/// 用来创建[ViewModel]的工厂
class GlobalViewModelFactory extends ViewModelFactory {
  const GlobalViewModelFactory();

  @override
  T create<T extends ViewModel>() {
    var viewModelCreate = _vmCreateMap[T];
    if (viewModelCreate == null) {
      throw Exception(
          "Unknown ViewModel type:$T, 请调用[registerGlobalViewModel]注册ViewModel.");
    }
    return viewModelCreate() as T;
  }
}

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
      viewModelFactory: viewModelFactory ?? const GlobalViewModelFactory(),
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

//endregion ---ViewModel---
