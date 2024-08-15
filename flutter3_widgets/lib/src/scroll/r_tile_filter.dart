part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/23
///
/// [RItemTile]过滤链
class RTileFilterChain {
  final List<BaseTileFilter> filterList;

  const RTileFilterChain(this.filterList);

  /// 执行过滤
  /// 输入原始的[children]输出过滤后的[children]
  @entryPoint
  WidgetList doFilter(WidgetList children) {
    WidgetList result = [];
    result.addAll(children);
    for (final filter in filterList) {
      if (filter.filterTile(children, result)) {
        break;
      }
    }
    return result;
  }
}

/// 过滤的基类
abstract class BaseTileFilter {
  const BaseTileFilter();

  /// 过滤函数, 返回true, 表示中断过滤
  @overridePoint
  bool filterTile(WidgetList origin, WidgetList result) {
    return false;
  }
}

class ItemTileFilter extends BaseTileFilter {
  const ItemTileFilter();

  @entryPoint
  @override
  bool filterTile(WidgetList origin, WidgetList result) {
    filterHide(origin, result);
    filterGroup(origin, result);
    return false;
  }

  //--hide

  /// 过滤掉[hide]为true的[Widget]
  void filterHide(WidgetList origin, WidgetList result) {
    final hideList = [];
    for (final child in result) {
      if (child is RItemTile) {
        if (child.hide) {
          hideList.add(child);
          hideList.addAll(getHideListFrom(result, child));
        }
      }
    }
    result.removeWhere((element) => hideList.contains(element));
  }

  WidgetList getHideListFrom(WidgetList list, Widget hide) {
    WidgetList result = [];
    for (final child in list) {
      if (child is RItemTile) {
        if (child != hide) {
          if (child.isHideFrom(hide)) {
            result.add(child);
            result.addAll(getHideListFrom(list, child));
          }
        }
      }
    }
    return result;
  }

  //--group

  /// 过滤group收起的tile
  void filterGroup(WidgetList origin, WidgetList result) {
    final hideList = [];
    for (final child in result) {
      if (child is RItemTile) {
        if (child.groupExpanded != null && child.groupExpanded == false) {
          //收起的group
          for (final sub in result) {
            if (sub is RItemTile) {
              if (sub.isInGroup(child)) {
                hideList.add(sub);
                hideList.addAll(getHideListFrom(result, sub));
              }
            }
          }
        }
      }
    }
    result.removeWhere((element) => hideList.contains(element));
  }
}
