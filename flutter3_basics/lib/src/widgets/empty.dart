part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/13
///

/// 一个空的占位小组件
class Empty extends StatelessWidget {
  final Size size;

  const Empty({super.key, required this.size});

  Empty.width(double width, {super.key}) : size = Size(width, 0);

  Empty.height(double height, {super.key}) : size = Size(0, height);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(size),
    );
  }
}
