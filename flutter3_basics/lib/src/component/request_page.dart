part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/08
///

class RequestPage {
  /// 默认一页请求的数量
  static var PAGE_SIZE = 20;

  /// 默认第一页的索引
  static var FIRST_PAGE_INDEX = 1;

  /// 单列表数据, 无加载更多
  static RequestPage singlePage() {
    return RequestPage()..requestPageSize = intMaxValue;
  }

  /// 默认的第一页
  var _firstPageIndex = FIRST_PAGE_INDEX;

  int get firstPageIndex => _firstPageIndex;

  set firstPageIndex(int value) {
    _firstPageIndex = value;
    pageRefresh();
  }

  /// 当前请求完成的页
  late var _currentPageIndex = firstPageIndex;

  /// 正在请求的页
  late var requestPageIndex = firstPageIndex;

  /// 每页请求的数量
  var requestPageSize = PAGE_SIZE;

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
  }

  /// 是否是第一页请求
  bool get isFirstPage => requestPageIndex <= firstPageIndex;

  /// 文件分页查询
  void filePage() {
    firstPageIndex = 0;
    _currentPageIndex = firstPageIndex;
    requestPageIndex = firstPageIndex;
  }

  @override
  String toString() {
    return "首页[$firstPageIndex],请求页[$requestPageIndex],请求数量[$requestPageSize].";
  }
}
