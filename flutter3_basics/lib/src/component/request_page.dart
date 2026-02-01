part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/08
///
/// 分页请求参数
/// 分页加载信息
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
}
