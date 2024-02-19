part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/19

/// [NotificationListener]
abstract class CanvasNotification extends Notification {}

/// 画布状态改变通知
class CanvasViewBoxChangedNotification extends CanvasNotification {
  CanvasViewBoxChangedNotification(this.canvasViewBox, this.isCompleted);

  final CanvasViewBox canvasViewBox;
  final bool isCompleted;
}
