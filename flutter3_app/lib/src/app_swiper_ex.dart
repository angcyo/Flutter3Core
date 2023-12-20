part of flutter3_app;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/20
///

typedef SwiperWidgetBuilder<T> = Widget Function(T element, int index);

extension AppSwiperEx<T> on List<T> {
  ///[Swiper]
  Widget toSwiper({
    bool loop = true,
    bool autoplay = true,
    SwiperController? swiperController,
    required SwiperWidgetBuilder<T> builder,
  }) {
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
      pagination: const SwiperPagination(),
    );
  }
}
