part of 'popup_mix.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
/// 提供一个popup容器的弹窗
class PopupContainerDialog extends StatefulWidget with TranslationTypeMixin {
  @defInjectMark
  final Widget? body;

  const PopupContainerDialog({super.key, this.body});

  @override
  State<PopupContainerDialog> createState() => _PopupContainerDialogState();
}

class _PopupContainerDialogState extends State<PopupContainerDialog> {
  @override
  Widget build(BuildContext context) {
    return widget.body ?? empty;
  }
}
