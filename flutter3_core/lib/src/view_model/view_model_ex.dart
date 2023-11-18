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

/// 全局[ViewModel]
final _vmMap = <Type, ViewModel>{};

/// 注册全局的[ViewModel]
void registerGlobalViewModel<T extends ViewModel>(T viewModel) {
  _vmMap[T] = viewModel;
}

/// 用来创建[ViewModel]的工厂
class GlobalViewModelFactory extends ViewModelFactory {
  const GlobalViewModelFactory();

  @override
  T create<T extends ViewModel>() {
    var viewModel = _vmMap[T];
    if (viewModel == null) {
      throw Exception("Unknown ViewModel type:$T");
    }
    return viewModel as T;
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
/// [ViewModelProviderExtension]
/// [LiveDataBuilder]
extension ViewModelWidgetEx on Widget {
  /// 全局的[ViewModelScope]
  /// [ViewModelFactoryProvider]
  Widget wrapGlobalViewModelProvider([ViewModelFactory? viewModelFactory]) {
    return ViewModelFactoryProvider(
      viewModelFactory: viewModelFactory ?? const GlobalViewModelFactory(),
      child: ViewModelScope(
        builder: (context) => this,
      ),
    );
  }

  ///
  Widget wrapViewModelListProvider(List<ViewModel> list) {
    return ViewModelFactoryProvider(
      viewModelFactory: ListViewModelFactory(list),
      child: ViewModelScope(
        builder: (context) => this,
      ),
    );
  }
}

//endregion ---ViewModel---
