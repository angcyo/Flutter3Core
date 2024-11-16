part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/11
///
/// 显示屏幕截图覆盖层, 并且点击触发分享日志
class ScreenCaptureOverlay {
  /// 显示
  @callPoint
  static Future showScreenCaptureOverlay() async {
    final path = await cacheFilePath("ScreenCapture${nowTimestamp()}.png");
    final image = await saveScreenCapture(path);
    if (image == null) {
      toastInfo('截屏失败');
    } else {
      addToShareLogPath(path);
      showOverlay((entry, state, context, progress) {
        return OpacityNotification(
          builder: (context) => _ScreenCaptureOverlayWidget(
            image: image,
            state: state,
          ),
          progress: progress,
        );
      });
    }
  }
}

class _ScreenCaptureOverlayWidget extends StatelessWidget {
  final UiImage? image;

  final OverlayAnimatedState state;

  const _ScreenCaptureOverlayWidget({
    super.key,
    this.image,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = GlobalTheme.of(context);
    const width = 80.0;
    const height = 100.0;
    return Stack(
      children: [
        Align(
          alignment: FractionalOffset.centerLeft,
          child: Container(
            width: width,
            height: height,
            color: Colors.black26,
            child: [
              image?.toImageWidget(),
              Icon(
                Icons.cancel_rounded,
                color: globalTheme.icoNormalColor,
              ).inkWellCircle(() {
                state.hide();
              }).position(right: 0, top: 0),
            ].stack(alignment: AlignmentDirectional.center),
          ).clipRadius().inkWell(() {
            state.hide();
            globalConfig.shareAppLogFn?.call(context, runtimeType);
          }),
        ),
      ],
    ).material().safeArea();
  }
}
