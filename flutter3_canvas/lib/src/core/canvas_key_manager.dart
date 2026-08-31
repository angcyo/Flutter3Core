part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 用来监听键盘事件
///
/// - [CanvasDelegate.canvasKeyManager] 的成员
///   - [CanvasKeyManager] 用来监听键盘事件
///   - [CanvasEventManager] 用来处理手势事件
///
class CanvasKeyManager
    with DiagnosticableTreeMixin, DiagnosticsMixin, CanvasDelegateManagerMixin {
  @override
  final CanvasDelegate canvasDelegate;

  CanvasKeyManager(this.canvasDelegate) {
    assert(() {
      l.i(
        "注册快捷键个数[${CanvasKeyActions.values.size()}]->"
        "[${shortcutConfigManager.shortcutConfigList.size()}/"
        "${shortcutConfigManager.shortcutActionMap.length}]!",
      );
      return true;
    }());
  }

  /// 复制的元素列表
  @tempFlag
  List<ElementPainter>? _copyElementList;

  String get keyTag => "$runtimeType";

  /// 注册所有键盘事件, 注册事件之后通过[KeyEventMixin.onHandleKeyEventMixin]入口进行分发处理
  ///
  /// - [registerKeyEventHandler] -> [KeyEventMixin.registerKeyEvent]
  /// - [unregisterKeyEventHandler]
  ///
  /// - [CanvasRenderBox.attach] 驱动
  @desktopFlag
  @callPoint
  void registerKeyEventHandler(CanvasRenderBox renderObject) {
    if (useNewShortcutConfig) {
      //空格键, 开启拖拽
      if (canvasStyle.dragKeyboardKey != null) {
        shortcutConfigManager.addShortcutConfig(
          ShortcutConfigBean.fromKey(
            canvasStyle.dragKeyboardKey,
            id: CanvasKeyActions.dragCanvas.id,
            labelAssetsKey: CanvasKeyActions.dragCanvas.assetsKey,
          ),
        );
      }
      //Ctrl键, 任意比例缩放
      if (canvasStyle.ignoreLockKeyboardKey != null) {
        shortcutConfigManager.addShortcutConfig(
          ShortcutConfigBean.fromKey(
            canvasStyle.ignoreLockKeyboardKey,
            id: CanvasKeyActions.ignoreLocalRatio.id,
            labelAssetsKey: CanvasKeyActions.ignoreLocalRatio.assetsKey,
          ),
        );
      }
      //删除选中元素
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.delete,
          id: CanvasKeyActions.deleteSelectedElement.id,
          labelAssetsKey: CanvasKeyActions.deleteSelectedElement.assetsKey,
        ),
      );
      //方向键, 移动选中元素
      shortcutConfigManager
        ..addShortcutConfig(
          ShortcutConfigBean.fromKey(
            LogicalKeyboardKey.arrowUp,
            id: CanvasKeyActions.moveElementUp.id,
            labelAssetsKey: CanvasKeyActions.moveElementUp.assetsKey,
          ),
        )
        ..addShortcutConfig(
          ShortcutConfigBean.fromKey(
            LogicalKeyboardKey.arrowDown,
            id: CanvasKeyActions.moveElementDown.id,
            labelAssetsKey: CanvasKeyActions.moveElementDown.assetsKey,
          ),
        )
        ..addShortcutConfig(
          ShortcutConfigBean.fromKey(
            LogicalKeyboardKey.arrowLeft,
            id: CanvasKeyActions.moveElementLeft.id,
            labelAssetsKey: CanvasKeyActions.moveElementLeft.assetsKey,
          ),
        )
        ..addShortcutConfig(
          ShortcutConfigBean.fromKey(
            LogicalKeyboardKey.arrowRight,
            id: CanvasKeyActions.moveElementRight.id,
            labelAssetsKey: CanvasKeyActions.moveElementRight.assetsKey,
          ),
        );

      //撤销
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyZ,
          id: CanvasKeyActions.undo.id,
          labelAssetsKey: CanvasKeyActions.undo.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );

      //重做
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyY,
          id: CanvasKeyActions.redo.id,
          labelAssetsKey: CanvasKeyActions.redo.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
          shift: !isMacOS,
        ),
      );

      //复制
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyC,
          id: CanvasKeyActions.copyElement.id,
          labelAssetsKey: CanvasKeyActions.copyElement.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );
      //粘贴
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyV,
          id: CanvasKeyActions.pasteElement.id,
          labelAssetsKey: CanvasKeyActions.pasteElement.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );

      //全选
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyA,
          id: CanvasKeyActions.selectAllElement.id,
          labelAssetsKey: CanvasKeyActions.selectAllElement.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );

      //放大画布
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.equal,
          id: CanvasKeyActions.zoomIn.id,
          labelAssetsKey: CanvasKeyActions.zoomIn.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );
      //缩小画布
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.minus,
          id: CanvasKeyActions.zoomOut.id,
          labelAssetsKey: CanvasKeyActions.zoomOut.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );
      //组合
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyG,
          id: CanvasKeyActions.groupElement.id,
          labelAssetsKey: CanvasKeyActions.groupElement.assetsKey,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );
      //取消组合
      shortcutConfigManager.addShortcutConfig(
        ShortcutConfigBean.fromKey(
          LogicalKeyboardKey.keyG,
          id: CanvasKeyActions.ungroupElement.id,
          labelAssetsKey: CanvasKeyActions.ungroupElement.assetsKey,
          shift: true,
          meta: isMacOS,
          control: !isMacOS,
        ),
      );
      return;
    }
    //--old
    //空格键, 开启拖拽
    if (canvasStyle.dragKeyboardKey != null) {
      renderObject.registerKeyEvent(
        [
          [canvasStyle.dragKeyboardKey!],
        ],
        (info) {
          if (info.isKeyDown) {
            canvasDelegate.updateCanvasStyleModeChanged(
              CanvasStyleMode.dragMode,
            );
            //canvasDelegate.addCursorStyle("drag", SystemMouseCursors.click);
          } else if (info.isKeyUp) {
            canvasDelegate.updateCanvasStyleModeChanged(null);
            //canvasDelegate.removeCursorStyle("drag", SystemMouseCursors.click);
          }
          renderObject.markNeedsPaint();
          //renderObject.postMarkNeedsPaint();
          return .handled;
        },
        keyRepeat: true,
        keyUp: true,
        tag: keyTag,
      );
    }

    //Ctrl键, 任意比例缩放
    if (canvasStyle.ignoreLockKeyboardKey != null) {
      renderObject.registerKeyEvent(
        [
          [canvasStyle.ignoreLockKeyboardKey!],
        ],
        (info) {
          //l.i("info->$info");
          final lockControl = canvasDelegate
              .canvasElementManager
              .canvasElementControlManager
              .lockControl;
          if (info.isKeyDown) {
            lockControl.setIgnoreLockRatio(true);
          } else if (info.isKeyUp) {
            lockControl.setIgnoreLockRatio(false);
          }
          return .handled;
        },
        keyUp: true,
        tag: keyTag,
      );
    }

    //删除选中元素
    renderObject.registerKeyEvent(
      [
        [LogicalKeyboardKey.delete],
        [LogicalKeyboardKey.backspace],
      ],
      (info) {
        deleteSelectedElement();
        return .handled;
      },
      tag: keyTag,
    );

    //方向键, 移动选中元素
    renderObject.registerKeyEvent(
      [
        [LogicalKeyboardKey.arrowUp],
        [LogicalKeyboardKey.arrowDown],
        [LogicalKeyboardKey.arrowLeft],
        [LogicalKeyboardKey.arrowRight],
      ],
      (info) {
        final canvasElementControlManager =
            canvasElementManager.canvasElementControlManager;
        if (canvasElementControlManager.isSelectedElement) {
          renderObject.requestFocus();
          final offset =
              (isCtrlPressed
                      ? canvasStyle.canvasArrowAdjustFastOffset
                      : canvasStyle.canvasArrowAdjustOffset)
                  .toOffsetDp();
          final dx = info.keys.contains(LogicalKeyboardKey.arrowLeft)
              ? -offset.dx
              : info.keys.contains(LogicalKeyboardKey.arrowRight)
              ? offset.dx
              : 0.0;
          final dy = info.keys.contains(LogicalKeyboardKey.arrowUp)
              ? -offset.dy
              : info.keys.contains(LogicalKeyboardKey.arrowDown)
              ? offset.dy
              : 0.0;
          canvasElementControlManager.translateElement(
            canvasElementManager.selectComponent,
            dx: dx,
            dy: dy,
          );
        }
        return .handled;
      },
      matchKeyCount: false,
      tag: keyTag,
    );

    //撤销
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ],
        ],
      ],
      (info) {
        undo();
        return .handled;
      },
      tag: keyTag,
    );

    //重做
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyY],
        ],
        if (!isMacOS) ...[
          [
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyZ,
          ],
        ],
      ],
      (info) {
        redo();
        return .handled;
      },
      tag: keyTag,
    );

    //复制
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.keyC],
        ],
      ],
      (info) {
        return copySelectedElement() ? .handled : .ignored;
      },
      tag: keyTag,
    );

    //粘贴
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.keyV],
        ],
      ],
      (info) {
        return pasteSelectedElement() ? .handled : .ignored;
      },
      tag: keyTag,
    );

    //全选
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyA],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.keyA],
        ],
      ],
      (info) {
        selectAllElement();
        return .handled;
      },
      tag: keyTag,
    );

    //放大画布
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.equal],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.equal],
        ],
      ],
      (info) {
        zoomIn();
        return .handled;
      },
      tag: keyTag,
    );

    //缩小画布
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.minus],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.minus],
        ],
      ],
      (info) {
        zoomOut();
        return .handled;
      },
      tag: keyTag,
    );

    //组合
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyG],
        ],
        if (!isMacOS) ...[
          [LogicalKeyboardKey.control, LogicalKeyboardKey.keyG],
        ],
      ],
      (info) {
        groupSelectedElement();
        return .handled;
      },
      tag: keyTag,
    );

    //取消组合
    renderObject.registerKeyEvent(
      [
        if (isMacOS) ...[
          [
            LogicalKeyboardKey.meta,
            LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyG,
          ],
        ],
        if (!isMacOS) ...[
          [
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyG,
          ],
        ],
      ],
      (info) {
        ungroupSelectedElement();
        return .handled;
      },
      tag: keyTag,
    );
  }

  /// 取消所有按键的注册
  /// - [registerKeyEventHandler]
  /// - [unregisterKeyEventHandler]
  @callPoint
  void unregisterKeyEventHandler(CanvasRenderBox renderObject) {
    shortcutConfigManager.clearShortcutConfig();
    //shortcutConfigManager.clearShortcutAction();
    renderObject.removeAllKeyEventRegister(tag: keyTag);
  }

  /// 新的按键事件处理
  /// - [CanvasRenderBox.handleKeyEventResultMixin]驱动
  @callPoint
  KeyEventResult handleKeyEvent(CanvasRenderBox renderObject, KeyEvent event) {
    //触发注册的快捷键
    final result = shortcutConfigManager.triggerShortcutAction(
      event: event,
      host: canvasDelegate,
      data: renderObject,
    );
    return result ?? KeyEventResult.ignored;
  }

  //--

  /// 撤销
  @api
  FutureOr<bool> undo() {
    return canvasUndoManager.undo();
  }

  /// 重做
  @api
  FutureOr<bool> redo() {
    return canvasUndoManager.redo();
  }

  //--

  /// 复制选中的元素
  @api
  bool copySelectedElement() {
    if (isSelectedElement) {
      clearClipboard();
      () async {
        _copyElementList = await canvasElementManager.copySelectedElement(
          autoAddToCanvas: false,
        );
      }();
      return true;
    } else {
      return false;
    }
  }

  /// 复制元素列表
  @api
  Future<List<ElementPainter>?> copyElementList(
    List<ElementPainter>? elementList,
  ) async {
    return canvasElementManager.copyElementList(
      elementList,
      autoAddToCanvas: false,
    );
  }

  /// 粘贴选中的元素
  @api
  bool pasteSelectedElement() {
    //debugger();
    if (!isNil(_copyElementList)) {
      //为了下一次继续粘贴, 这里需要重新复制一份
      () async {
        final elementList = await _copyElementList!.copyElementList();
        canvasElementManager.addElementList(
          elementList,
          selected: true,
          followPainter: !isDesktopOrWeb,
          offset: canvasStyle.canvasCopyOffset.toOffsetDp(),
        );
        _copyElementList = elementList;
      }();
      return true;
    }
    return false;
  }

  /// 选择所有元素
  @api
  bool selectAllElement() {
    canvasElementManager.selectAllElement();
    return true;
  }

  /// 删除选中的元素
  @api
  bool deleteSelectedElement() {
    return canvasElementManager.canvasElementControlManager
        .removeSelectedElement();
  }

  /// 删除元素
  @api
  @supportUndo
  bool deleteElementList(
    List<ElementPainter>? list, {
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    return canvasElementManager.removeElementList(
      list,
      undoType: undoType,
      selectType: selectType,
    );
  }

  //--

  /// 放大画布
  @api
  void zoomIn({@viewCoordinate Offset? anchorPosition, bool anim = true}) {
    final canvasScaleComponent = canvasEventManager.canvasScaleComponent;
    canvasViewBox.scaleBy(
      sx: canvasScaleComponent.doubleScaleValue,
      sy: canvasScaleComponent.doubleScaleValue,
      pivot: anchorPosition != null
          ? canvasViewBox.toScenePoint(anchorPosition)
          : canvasViewBox.canvasSceneVisibleBounds.center,
      anim: anim,
    );
  }

  /// 缩小画布
  @api
  void zoomOut({@viewCoordinate Offset? anchorPosition, bool anim = true}) {
    final canvasScaleComponent = canvasEventManager.canvasScaleComponent;
    canvasViewBox.scaleBy(
      sx: canvasScaleComponent.doubleScaleReverseValue,
      sy: canvasScaleComponent.doubleScaleReverseValue,
      pivot: anchorPosition != null
          ? canvasViewBox.toScenePoint(anchorPosition)
          : canvasViewBox.canvasSceneVisibleBounds.center,
      anim: anim,
    );
  }

  //--

  /// 组合选中元素
  @api
  bool groupSelectedElement() {
    return canvasElementManager.groupElement(
      canvasElementManager.elementSelectComponent?.children,
    );
  }

  /// 解组选中的元素
  @api
  bool ungroupSelectedElement() {
    return canvasElementManager.ungroupElement(
      canvasElementManager.selectedElement,
    );
  }

  //MARK - ShortcutConfig

  /// 是否使用新的快捷键配置
  bool useNewShortcutConfig = true;

  /// 快捷键配置管理
  late ShortcutConfigManager shortcutConfigManager = ShortcutConfigManager()
    ..registerShortcutAction(CanvasKeyActions.dragCanvas.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event != null) {
        if (event.isKeyDown) {
          canvasDelegate.updateCanvasStyleModeChanged(CanvasStyleMode.dragMode);
          //canvasDelegate.addCursorStyle("drag", SystemMouseCursors.click);
        } else if (event.isKeyUp) {
          canvasDelegate.updateCanvasStyleModeChanged(null);
          //canvasDelegate.removeCursorStyle("drag", SystemMouseCursors.click);
        }
        if (data is RenderObject) {
          data.markNeedsPaint();
        }
        //renderObject.postMarkNeedsPaint();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.ignoreLocalRatio.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event != null) {
        final lockControl = canvasDelegate
            .canvasElementManager
            .canvasElementControlManager
            .lockControl;
        if (event.isKeyDown) {
          lockControl.setIgnoreLockRatio(true);
        } else if (event.isKeyUp) {
          lockControl.setIgnoreLockRatio(false);
        }
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.deleteSelectedElement.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        deleteSelectedElement();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.moveElementUp.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        final canvasElementControlManager =
            canvasElementManager.canvasElementControlManager;
        if (canvasElementControlManager.isSelectedElement) {
          //renderObject.requestFocus();
          final offset =
              (isCtrlPressed
                      ? canvasStyle.canvasArrowAdjustFastOffset
                      : canvasStyle.canvasArrowAdjustOffset)
                  .toOffsetDp();
          canvasElementControlManager.translateElement(
            canvasElementManager.selectComponent,
            dx: 0,
            dy: -offset.dy,
          );
        }
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.moveElementDown.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        final canvasElementControlManager =
            canvasElementManager.canvasElementControlManager;
        if (canvasElementControlManager.isSelectedElement) {
          //renderObject.requestFocus();
          final offset =
              (isCtrlPressed
                      ? canvasStyle.canvasArrowAdjustFastOffset
                      : canvasStyle.canvasArrowAdjustOffset)
                  .toOffsetDp();
          canvasElementControlManager.translateElement(
            canvasElementManager.selectComponent,
            dx: 0,
            dy: offset.dy,
          );
        }
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.moveElementLeft.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        final canvasElementControlManager =
            canvasElementManager.canvasElementControlManager;
        if (canvasElementControlManager.isSelectedElement) {
          //renderObject.requestFocus();
          final offset =
              (isCtrlPressed
                      ? canvasStyle.canvasArrowAdjustFastOffset
                      : canvasStyle.canvasArrowAdjustOffset)
                  .toOffsetDp();
          canvasElementControlManager.translateElement(
            canvasElementManager.selectComponent,
            dx: -offset.dx,
            dy: 0,
          );
        }
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.moveElementRight.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        final canvasElementControlManager =
            canvasElementManager.canvasElementControlManager;
        if (canvasElementControlManager.isSelectedElement) {
          //renderObject.requestFocus();
          final offset =
              (isCtrlPressed
                      ? canvasStyle.canvasArrowAdjustFastOffset
                      : canvasStyle.canvasArrowAdjustOffset)
                  .toOffsetDp();
          canvasElementControlManager.translateElement(
            canvasElementManager.selectComponent,
            dx: offset.dx,
            dy: 0,
          );
        }
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.undo.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        undo();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.redo.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        redo();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.copyElement.id, (
      ctx,
      event,
      host,
      data,
    ) {
      return copySelectedElement() ? .handled : .ignored;
    })
    ..registerShortcutAction(CanvasKeyActions.pasteElement.id, (
      ctx,
      event,
      host,
      data,
    ) {
      return event?.isKeyDown == true && pasteSelectedElement()
          ? .handled
          : .ignored;
    })
    ..registerShortcutAction(CanvasKeyActions.selectAllElement.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        selectAllElement();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.zoomIn.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        zoomIn();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.zoomOut.id, (
      ctx,
      event,
      host,
      data,
    ) {
      if (event?.isKeyDown == true) {
        zoomOut();
      }
      return .handled;
    })
    ..registerShortcutAction(CanvasKeyActions.groupElement.id, (
      ctx,
      event,
      host,
      data,
    ) {
      return event?.isKeyDown == true && groupSelectedElement()
          ? .handled
          : .ignored;
    })
    ..registerShortcutAction(CanvasKeyActions.ungroupElement.id, (
      ctx,
      event,
      host,
      data,
    ) {
      return event?.isKeyDown == true && ungroupSelectedElement()
          ? .handled
          : .ignored;
    });
}

/// 画布按键操作
enum CanvasKeyActions {
  dragCanvas("canvas_drag_canvas", "libDragCanvas", "拖拽画布"),
  ignoreLocalRatio("canvas_ignore_local_ratio", "libIgnoreLockRatio", "忽略锁定比例"),
  deleteSelectedElement(
    "canvas_delete_selected_element",
    "libDeleteSelectedElem",
    "删除选中的元素",
  ),
  moveElementUp("canvas_move_element_up", "libMoveElemUp", "向上移动元素"),
  moveElementDown("canvas_move_element_down", "libMoveElemDown", "向下移动元素"),
  moveElementLeft("canvas_move_element_left", "libMoveElemLeft", "向左移动元素"),
  moveElementRight("canvas_move_element_right", "libMoveElemRight", "向右移动元素"),
  undo("canvas_undo", "libUndo", "撤销"),
  redo("canvas_redo", "libRedo", "重做"),
  copyElement("canvas_copy_selected_element", "libCopySelectedElem", "复制选中元素"),
  pasteElement(
    "canvas_paste_selected_element",
    "libPasteSelectedElem",
    "粘贴选中元素",
  ),
  selectAllElement("canvas_select_all_element", "libSelectAll", "全选"),
  zoomIn("canvas_zoom_in", "libZoomInCanvas", "放大画布"),
  zoomOut("canvas_zoom_out", "libZoomOutCanvas", "缩小画布"),
  groupElement("canvas_group_element", "libGroupElements", "组合元素"),
  ungroupElement("canvas_ungroup_element", "libUngroupElements", "解组元素");

  const CanvasKeyActions(this.id, this.assetsKey, this.des);

  final String id;
  final String des;
  final String? assetsKey;
}
