part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/20
///

typedef SwiperWidgetBuilder<T> = Widget Function(T element, int index);

extension AppSwiperEx<T> on List<T> {
  ///[Swiper]
  ///[paginationThreshold] 页码指示器的阈值, 当数量大于这个值时, 使用页面指示器
  ///[FractionPaginationBuilder]
  ///[DotSwiperPaginationBuilder]
  ///
  /// [autoplayDelay] 自动播放延迟时长, 默认3000ms
  /// [duration] 动画过度时长
  Widget toSwiper({
    bool loop = true,
    bool autoplay = true,
    SwiperController? swiperController,
    int paginationThreshold = 10,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    int duration = kDefaultAutoplayTransactionDuration,
    required SwiperWidgetBuilder<T> builder,
  }) {
    var swiperPagination = SwiperPagination(
        margin: length >= paginationThreshold
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(10.0),
        builder: length >= paginationThreshold
            ? const FractionPaginationBuilder(fontSize: 12, activeFontSize: 20)
            : SwiperPagination.dots);
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
}
