part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/05
///
/// 用来跟踪[RItemTile]并rebuild
///
/// 通过[rebuildByBean]创建一个对应的[UpdateSignalNotifier]信号,
/// 并通过[RScrollPage.consumeRebuildBeanSignal]来使用这个信号,
/// 之后通过[updateTile]/[rebuildTile]刷新对应的[RItemTile]
///
/// 在不使用[RScrollPage]时单独使用此混入.
/// [RScrollPage.consumeRebuildBeanSignal]
///
mixin RTileRebuildMixin {
  /// [RScrollPage.pageWidgetList]
  WidgetList tileWidgetList = [];

  /// 刷新信号
  final UpdateValueNotifier tileUpdateSignal = $signal();

  /// 清除缓存
  @api
  void clearTileWidgetList() {
    tileWidgetList.clear();
  }

  /// 收集[RItemTile], 以便[rebuildTile]能检索到
  /// [tileWidgetList]
  @api
  Widget hookTile(Widget tile) {
    tileWidgetList.add(tile);
    return tile;
  }

  //--

  /// [RScrollPage.rebuildByBean]
  @api
  Widget rebuildByBean<Bean>(Bean bean, DataWidgetBuilder<Bean> builder) {
    final updateSignal = UpdateSignalNotifier(bean);
    RScrollPage._lastRebuildBeanSignal = WeakReference(updateSignal);
    return rebuild(updateSignal, (context, value) => builder(context, value));
  }

  /// [RScrollPage.updateTile]
  @api
  void updateTile<T>(
    T value, {
    void Function(T oldValue)? onUpdateValueAction,
  }) {
    rebuildTile((tile, signal) {
      //debugger();
      final update =
          signal.value == value ||
          (value is Iterable && value.contains(signal.value));
      if (update) {
        /*debugger();
        if (signal is ValueNotifier) {
          //先清空, 后赋值. 否则id相同时, 其它字段不同, 不会更新
          signal.value = null;//不支持
          signal.value = value;
        }*/
        onUpdateValueAction?.call(signal.value);
        assert(() {
          if (update) {
            l.d("找到需要更新[${tile.classHash()}]->$value");
          }
          return true;
        }());
      }
      return update;
    });
  }

  /// [RScrollPage.rebuildTile]
  @api
  void rebuildTile(bool Function(Widget tile, Listenable signal) test) {
    for (final element in tileWidgetList) {
      //debugger();
      Listenable? updateSignal = element.tileUpdateSignal;
      if (updateSignal != null) {
        try {
          if (test(element, updateSignal)) {
            //debugger();
            if (updateSignal is UpdateSignalNotifier) {
              updateSignal.updateValue();
            } else if (updateSignal is ChangeNotifier) {
              updateSignal.notifyListeners();
            } else {
              debugger();
            }
          }
        } catch (e) {
          //中断循环
          assert(() {
            printError(e);
            return true;
          }());
          break;
        }
      }
    }
  }

  //--

  /// [RScrollPage.removeTile]
  @api
  void removeTile(dynamic value) {
    deleteTile((tile, signal) {
      return signal.value == value ||
          (value is Iterable && value.contains(signal.value));
    });
  }

  /// [RScrollPage.deleteTile]
  @api
  void deleteTile(bool Function(Widget tile, Listenable signal) test) {
    final WidgetList removeList = [];
    for (final element in tileWidgetList) {
      //debugger();
      Listenable? updateSignal = element.tileUpdateSignal;
      if (updateSignal != null) {
        try {
          if (test(element, updateSignal)) {
            //debugger();
            removeList.add(element);
          }
        } catch (e) {
          //中断循环
          assert(() {
            printError(e);
            return true;
          }());
          break;
        }
      }
    }
    if (removeList.isNotEmpty) {
      tileWidgetList.removeAll(removeList);
      tileUpdateSignal.update();
    }
  }
}
