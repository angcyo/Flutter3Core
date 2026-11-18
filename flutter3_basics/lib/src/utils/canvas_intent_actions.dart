part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/18
///
/// 画布按键操作定义列表
enum CanvasIntentActions {
  dragCanvas("canvas.drag.canvas", "libDragCanvas", "拖拽画布"),
  scaleCanvas("canvas.scale.canvas", "libScaleCanvas", "缩放画布"),
  multiSelectElement(
    "canvas.multi.select.element",
    "libMultiSelectElement",
    "多选元素",
  ),
  ignoreLocalRatio("canvas.ignore.local.ratio", "libIgnoreLockRatio", "忽略锁定比例"),
  measureDistance(
    "canvas.measure.distance",
    "libCanvasMeasureDistance",
    "画布测距",
  ),
  ignoreSmartAdsorption(
    "canvas.ignore.smart.adsorption",
    "libIgnoreSmartAdsorption",
    "忽略智能吸附",
  ),
  deleteSelectedElement(
    "canvas.delete.selected.element",
    "libDeleteSelectedElem",
    "删除选中的元素",
  ),
  moveElementUp("canvas.move.element.up", "libMoveElemUp", "向上移动元素"),
  moveElementDown("canvas.move.element.down", "libMoveElemDown", "向下移动元素"),
  moveElementLeft("canvas.move.element.left", "libMoveElemLeft", "向左移动元素"),
  moveElementRight("canvas.move.element.right", "libMoveElemRight", "向右移动元素"),
  moveFastElementUp(
    "canvas.move.fast.element.up",
    "libMoveFastElemUp",
    "向上快速移动元素",
  ),
  moveFastElementDown(
    "canvas.move.fast.element.down",
    "libMoveFastElemDown",
    "向下快速移动元素",
  ),
  moveFastElementLeft(
    "canvas.move.fast.element.left",
    "libMoveFastElemLeft",
    "向左快速移动元素",
  ),
  moveFastElementRight(
    "canvas.move.fast.element.right",
    "libMoveFastElemRight",
    "向右快速移动元素",
  ),
  undo("canvas.undo", "libUndo", "撤销"),
  redo("canvas.redo", "libRedo", "重做"),
  copyElement("canvas.copy.selected.element", "libCopySelectedElem", "复制选中元素"),
  pasteElement(
    "canvas.paste.selected.element",
    "libPasteSelectedElem",
    "粘贴选中元素",
  ),
  selectAllElement("canvas.select.all.element", "libSelectAll", "全选"),
  zoomIn("canvas.zoom.in", "libZoomInCanvas", "放大画布"),
  zoomOut("canvas.zoom.out", "libZoomOutCanvas", "缩小画布"),
  groupElement("canvas.group.element", "libGroupElements", "组合元素"),
  ungroupElement("canvas.ungroup.element", "libUngroupElements", "解组元素");

  const CanvasIntentActions(this.id, this.resKey, this.des);

  final String id;
  final String des;
  final String? resKey;
}
