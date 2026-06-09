part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/08
///
/// 分页请求参数
/// 分页加载信息
///
/// - 排序信息
///   - asc = Ascending → 升序（正序）
///   - desc = Descending → 降序（倒序）
class RequestPage {
  /// 默认一页请求的数量
  static var kPageSize = 20;

  /// 默认第一页的索引
  static var kFirstPageIndex = 1;

  /// 请求体中, 默认的header key
  static var kKeyPageIndex = "pageNo";
  static var kKeyPageSize = "pageSize";

  /// 单列表数据, 无加载更多
  static RequestPage createSinglePage() {
    return RequestPage()..requestPageSize = intMaxValue;
  }

  /// 网络请求中的header key
  @property
  var keyPageIndex = kKeyPageIndex;

  @property
  var keyPageSize = kKeyPageSize;

  /// 默认的第一页
  var _firstPageIndex = kFirstPageIndex;

  @property
  int get firstPageIndex => _firstPageIndex;

  set firstPageIndex(int value) {
    _firstPageIndex = value;
    pageRefresh();
  }

  /// 当前请求完成的页
  late var _currentPageIndex = firstPageIndex;

  /// 正在请求的页
  @property
  late var requestPageIndex = firstPageIndex;

  /// 每页请求的数量
  @property
  var requestPageSize = kPageSize;

  /// 当前请求开始的索引
  int get currentStartIndex =>
      (requestPageIndex - firstPageIndex) * requestPageSize;

  /// 当前请求结束的索引
  int get currentEndIndex => currentStartIndex + requestPageSize;

  /// 页面刷新, 重置page index
  void pageRefresh() {
    _currentPageIndex = firstPageIndex;
    requestPageIndex = firstPageIndex;
  }

  /// 页面加载更多
  void pageLoadMore() {
    requestPageIndex = _currentPageIndex + 1;
  }

  /// 页面加载结束, 刷新结束/加载更多结束
  void pageLoadEnd() {
    _currentPageIndex = requestPageIndex;
  }

  /// 重新赋值
  void set(RequestPage page) {
    firstPageIndex = page.firstPageIndex;
    _currentPageIndex = page._currentPageIndex;
    requestPageIndex = page.requestPageIndex;
    requestPageSize = page.requestPageSize;
    keyPageIndex = page.keyPageIndex;
    keyPageSize = page.keyPageSize;
  }

  /// 是否是第一页请求
  bool get isFirstPage => requestPageIndex <= firstPageIndex;

  /// 是否是当前页, 也就是当前页的数据加载完毕了
  bool get isCurrentPage => requestPageIndex == _currentPageIndex;

  /// 重置分页信息
  void reset() {
    pageRefresh();
  }

  /// 文件分页查询
  void filePage() {
    firstPageIndex = 0;
    _currentPageIndex = firstPageIndex;
    requestPageIndex = firstPageIndex;
  }

  /// 单列表数据, 无加载更多
  void singlePage() {
    requestPageSize = intMaxValue;
  }

  @override
  String toString() {
    return "首页[$firstPageIndex],当前页[$_currentPageIndex],请求页[$requestPageIndex],请求数量[$requestPageSize].";
  }

  //MARK: - method

  /// 请求体重中的参数
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[keyPageIndex] = requestPageIndex;
    map[keyPageSize] = requestPageSize;
    return map;
  }

  RequestPage copyWith({
    int? firstPageIndex,
    int? requestPageIndex,
    int? requestPageSize,
    String? keyPageIndex,
    String? keyPageSize,
  }) {
    return RequestPage()
      ..firstPageIndex = firstPageIndex ?? this.firstPageIndex
      .._currentPageIndex = _currentPageIndex
      ..requestPageIndex = requestPageIndex ?? this.requestPageIndex
      ..requestPageSize = requestPageSize ?? this.requestPageSize
      ..keyPageIndex = keyPageIndex ?? this.keyPageIndex
      ..keyPageSize = keyPageSize ?? this.keyPageSize;
  }

  //MARK: - sort 排序

  /// 排序方式是否发生改变的通知
  final sortLive = $liveOnce<bool>();

  /// 是否有排序规则
  bool get hasSort => sortField != null;

  /// 排序字段
  String? sortField;

  /// 排序方式: 是否倒序
  /// - 默认升序 -> 降序 -> 重置
  bool? reversed;

  /// 是否允许排序字段重置
  /// - 降序后 再次点击 是否重置排序字段?
  bool? enableResetSort = true;

  /// 更新排序字段
  /// @return true: 排序字段发生改变
  @api
  bool updateSort(String? field, {bool? reversed, bool? enableResetSort}) {
    if (reversed != null) {
      //更新当前字段的升降序
      sortField = field ?? sortField;
      if (this.reversed != reversed) {
        this.reversed = reversed;
        sortLive << true;
        return true;
      }
    } else if (field != null) {
      if (sortField != field) {
        //更新新的字段
        this.reversed = reversed ?? false;
        sortField = field;
        sortLive << true;
      } else {
        //切换相同的字段升降序
        if (this.reversed != true) {
          //当前未设置为降序/或已是升序
          this.reversed = true;
          sortLive << true;
        } else if (this.reversed == true) {
          //当前是降序
          enableResetSort ??= this.enableResetSort;
          if (enableResetSort == true) {
            //重置排序字段
            sortField = null;
            this.reversed = null;
            sortLive << true;
          } else {
            //切换到升序
            this.reversed = false;
            sortLive << true;
          }
        }
      }
      return true;
    } else if (sortField != null) {
      //清除排序字段
      sortField = null;
      this.reversed = null;
      sortLive << true;
      return true;
    }
    return false;
  }

  /// 构建排序小部件
  /// - [child] 默认的子部件
  /// - [sortField] 当前子部件的排序字段, 不指定则不激活
  /// - [ascIcon] 升序图标, 默认
  /// - [descIcon] 降序图标, 默认
  ///
  /// - [onSortAction] 排序成功后的回调, 在此回调中更新界面
  ///
  /// @return 带排序提示的小部件
  @api
  WidgetOf buildSortWidget(
    BuildContext context,
    WidgetOf child,
    String? sortField, {
    Widget? ascIcon,
    Widget? descIcon,
    VoidAction? onSortAction,
    //--
    bool? enableResetSort,
    //--row
    MainAxisSize? mainAxisSize,
    MainAxisAlignment? mainAxisAlignment = .center,
    double? gap = kM,
  }) {
    //debugger();

    if (sortField == null) {
      return child;
    }
    if (ascIcon == null && descIcon == null) {
      return child;
    }

    //--
    Widget? result = widgetOf(
      context,
      child,
      tryTextWidget: true,
      textAlign: switch (mainAxisAlignment) {
        MainAxisAlignment.start => TextAlign.start,
        MainAxisAlignment.end => TextAlign.end,
        MainAxisAlignment.center => TextAlign.center,
        _ => null,
      },
    );
    if (this.sortField != sortField) {
      //非当前的排序字段, 不显示图标
    } else if (reversed == true) {
      result = [result, descIcon].row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        gap: gap,
      );
    } else {
      result = [result, ascIcon].row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        gap: gap,
      );
    }

    return result?.click(() {
      if (updateSort(sortField, enableResetSort: enableResetSort)) {
        onSortAction?.call();
      }
    });
  }
}
