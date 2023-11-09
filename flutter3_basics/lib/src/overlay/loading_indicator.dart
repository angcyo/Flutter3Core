part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/07
///

/// 加载圈圈最小的尺寸大小
const double kMinLoadingIndicatorDimension = 24.0;

class LoadingIndicator extends StatelessWidget {
  final Size? size;

  const LoadingIndicator({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    double width = size?.width ?? kMinLoadingIndicatorDimension;
    double height = size?.height ?? kMinLoadingIndicatorDimension;
    return UnconstrainedBox(
      child: SizedBox(
        width: width,
        height: height,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
