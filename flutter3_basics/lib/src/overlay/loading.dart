part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/27
///

/// 显示加载提示
/// [showLoading] 加载提示core方法
/// [hideLoading] 隐藏加载提示
OverlayEntry? showStrokeLoading({
  BuildContext? context,
}) {
  final size = kDefaultLoadingSize;
  return showLoading(
    context: context,
    builder: (context, loadingInfo) {
      return const StrokeLoadingWidget(color: Colors.white)
          .container(
            color: Colors.black26,
            padding: const EdgeInsets.all(kM),
            radius: kDefaultBorderRadiusH,
            width: size.width,
            height: size.height,
          )
          .align(Alignment.center);
    },
  );
}
