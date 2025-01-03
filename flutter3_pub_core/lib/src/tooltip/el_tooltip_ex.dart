part of '../../flutter3_pub_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/02
///

/// [ElTooltip]
extension ElTooltipEx on Widget {
  /// [tooltip] 提示信息
  ///
  /// [showArrow] 是否显示箭头
  /// [showModal] 是否显示模态, 背景遮罩
  /// [showChildAboveOverlay] 是否显示子控件在模态 above
  ///
  /// [showHover] 鼠标经过时, 是否显示
  ///
  Widget elTooltip(
    Widget tooltip, {
    ElTooltipPosition position = ElTooltipPosition.topCenter,
    EdgeInsetsGeometry padding = const EdgeInsets.all(kX),
    Radius radius = const Radius.circular(kH),
    //--
    bool showArrow = true,
    bool showModal = false,
    bool showChildAboveOverlay = false,
    bool rootOverlay = true,
    //--
    Color color = Colors.white,
    Duration timeout = Duration.zero,
    ModalConfiguration modalConfiguration = const ModalConfiguration(),
    //--
    bool showShadow = true,
    bool? showHover,
    MouseCursor mouseCursor = SystemMouseCursors.click,
  }) {
    ElTooltipController? controller;
    /*showHover ??= !showModal;
    if (showHover) {
      controller = ElTooltipController();
    }*/
    Widget result = ElTooltip(
      content: tooltip,
      //--
      position: position,
      padding: padding,
      radius: radius,
      //
      showArrow: showArrow,
      showModal: showModal,
      showChildAboveOverlay: showChildAboveOverlay,
      rootOverlay: rootOverlay,
      //--
      color: color,
      timeout: timeout,
      modalConfiguration: modalConfiguration,
      //--
      contentWrapBuilder: showShadow
          ? (context, content) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: kShadowColor,
                      offset: kShadowOffset,
                      blurRadius: kDefaultBlurRadius,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: content!,
              );
            }
          : null,
      //--
      controller: controller,
      child: this,
    );
    /*if (showHover) {
      result = MouseRegion(
        cursor: mouseCursor,
        onHover: (event) {
          if (controller?.value == ElTooltipStatus.hidden) {
            controller?.show();
          }
        },
        onExit: (event) {
          if (controller?.value == ElTooltipStatus.showing) {
            controller?.hide();
          }
        },
        child: result,
      );
    }*/
    return result;
  }
}
