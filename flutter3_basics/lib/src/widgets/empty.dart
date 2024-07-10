part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/13
///

/// 一个空的占位小组件
/// [nil]
/// ```
/// // BEST
/// text != null ? Text(text) : nil
/// or
/// if (text != null) Text(text)
/// text != null ? Text(text) : const Container()/SizedBox()
/// ```
/// [nil]

Empty get empty => const Empty();

class Empty extends StatelessWidget {
  final Size? size;

  const Empty({super.key, this.size = Size.zero});

  const Empty.zero({super.key}) : size = const Size(0, 0);

  Empty.width(double width, {super.key}) : size = Size(width, 0);

  Empty.height(double height, {super.key}) : size = Size(0, height);

  @override
  Widget build(BuildContext context) {
    return size == null
        ? nil
        : ConstrainedBox(constraints: BoxConstraints.tight(size!));
  }
}

IgnoreWidget get ignoreWidget => const IgnoreWidget();

/// 当识别此小部件时, 表示要丢弃
class IgnoreWidget extends StatelessWidget {
  const IgnoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Empty();
  }
}
