part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/20
///

typedef SwiperWidgetBuilder<T> = Widget Function(T element, int index);

extension AppSwiperEx<T> on List<T> {
  ///[Swiper]轮播小部件
  ///[paginationThreshold] 页码指示器的阈值, 当页面数量大于这个值时, 使用页面数量指示器. 否则使用样式指示器.
  ///[FractionPaginationBuilder]
  ///[DotSwiperPaginationBuilder]
  ///
  /// [autoplayDelay] 自动播放延迟时长, 默认3000ms
  /// [duration] 动画过度时长
  ///
  /// [CarouselView]系统自带
  Widget toSwiper({
    bool loop = true,
    bool autoplay = true,
    SwiperController? swiperController,
    int paginationThreshold = 10,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    int duration = kDefaultAutoplayTransactionDuration,
    required SwiperWidgetBuilder<T> builder,
  }) {
    final swiperPagination = SwiperPagination(
      margin: length >= paginationThreshold
          ? const EdgeInsets.all(0)
          : const EdgeInsets.all(10.0),
      builder: length >= paginationThreshold
          ? const FractionPaginationBuilder(fontSize: 12, activeFontSize: 20)
          : SwiperPagination.dots,
    );
    return Swiper(
      itemCount: length,
      itemBuilder: (context, index) {
        return builder(this[index], index);
      },
      loop: loop,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: swiperController ?? SwiperController(),
      //control: const SwiperControl(),
      autoplay: autoplay,
      autoplayDelay: autoplayDelay,
      duration: duration,
      pagination: swiperPagination,
    );
  }

  /// 使用[Swiper]实现的垂直滚动轮播, 适用于公告通知
  /// ```
  /// [
  ///   "123".text().center().wrapContentHeight().toMarqueeWidget(),
  ///   "sadflkjsdfljsadlfjasdkfjlsd阿斯顿发斯蒂芬阿斯蒂芬拉水电费阿斯蒂芬萨达发斯蒂芬的"
  ///       .text()
  ///       .center()
  ///       .wrapContentHeight()
  ///       .toMarqueeWidget(),
  /// ].toNoticeSwiper().size(height: 40).bounds().rItemTile(),
  /// ```
  Widget toNoticeSwiper({
    bool loop = true,
    bool autoplay = true,
    SwiperController? swiperController,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    int duration = kDefaultAutoplayTransactionDuration,
    SwiperWidgetBuilder<T>? builder,
  }) {
    return Swiper(
      scrollDirection: .vertical,
      itemCount: length,
      itemBuilder: (context, index) {
        return builder?.call(this[index], index) ?? (this[index] as Widget);
      },
      loop: loop,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: swiperController ?? SwiperController(),
      //control: const SwiperControl(),
      autoplay: autoplay,
      autoplayDelay: autoplayDelay,
      duration: duration,
      pagination: null,
    );
  }
}
