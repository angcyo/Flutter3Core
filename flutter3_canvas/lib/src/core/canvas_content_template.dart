part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/10/21
///
/// 画布内容显示模版, 在[CanvasContentManager]中生效
class CanvasContentTemplate {
  /// 标签, 用来自定义的标识
  @configProperty
  String? tag;

  /// 自定义的模板数据
  @configProperty
  Object? data;

  //region ---内容边界---

  /// 限制内容场景的区域, 网格线只会在此区域内绘制
  ///
  /// 警示所有元素必须在此区域内
  /// [CanvasContentManager.withCanvasContent]
  ///
  /// [CanvasAxisManager.painting]
  /// [withCanvasContent]
  @dp
  @sceneCoordinate
  @clipFlag
  ContentPathPainterInfo? contentBackgroundInfo;

  /// 画布前景绘制, 不受[contentBackgroundInfo]clip影响
  @dp
  @sceneCoordinate
  ContentPathPainterInfo? contentForegroundInfo;

  //endregion ---内容边界---

  //region ---内容最佳区域---

  /// 场景内最佳区域范围, 应该在[contentBackgroundInfo]区域内
  /// 提示所有元素应该在此区域内
  @dp
  @sceneCoordinate
  ContentPathPainterInfo? contentOptimumInfo;

  //endregion ---内容最佳区域---

  /// 画布显示内容区域时, 要使用的跟随矩形信息,
  /// 不指定则会降级使用[contentBackgroundInfo]
  ///
  /// 通常这个位置也是推荐元素居中位置
  @dp
  @sceneCoordinate
  Rect? contentFollowRect;

  //region ---get---

  /// 画布跟随时的显示区域, 同时也是元素分配位置的参考
  @dp
  @sceneCoordinate
  Rect? get contentFollowRectInner =>
      contentFollowRect ??
      contentBackgroundInfo?.bounds ??
      contentOptimumInfo?.bounds;

//endregion ---get---
}
