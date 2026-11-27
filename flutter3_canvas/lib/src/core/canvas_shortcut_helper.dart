part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/17
///
/// 画布快捷方式工具
class CanvasShortcutHelper {
  CanvasShortcutHelper._();

  /// 画布默认的快捷键配置
  static List<ShortcutConfigBean> kCanvasShortcutConfigBeansList = [
    // 当按下此键时, 视为需要拖动画布
    ShortcutConfigBean.fromKey(
      .space,
      id: CanvasIntentActions.dragCanvas.id,
      isDefault: true,
      byKeyDown: true,
      byKeyUp: true,
    ),
    // 当按下此键时, 鼠标的滚动视为需要缩放画布
    ShortcutConfigBean.fromKey(
      .control,
      id: CanvasIntentActions.scaleCanvas.id,
      isDefault: true,
      byKeyDown: true,
      byKeyUp: true,
    ),
    // 当按下此键时, 鼠标点击视为多选元素
    ShortcutConfigBean.fromKey(
      .control,
      id: CanvasIntentActions.multiSelectElement.id,
      isDefault: true,
      byKeyDown: true,
      byKeyUp: true,
    ),
    // 当按下此键时, 视为忽略等比缩放
    ShortcutConfigBean.fromKey(
      .control,
      id: CanvasIntentActions.ignoreLocalRatio.id,
      isDefault: true,
      byKeyDown: true,
      byKeyUp: true,
    ),
    // 当按下此键时, 视为忽略智能吸附查询
    ShortcutConfigBean.fromKey(
      .control,
      id: CanvasIntentActions.ignoreSmartAdsorption.id,
      isDefault: true,
      byKeyDown: true,
      byKeyUp: true,
    ),
    // 当按下此键时, 激活画布测距功能
    ShortcutConfigBean.fromKey(
      .alt,
      id: CanvasIntentActions.measureDistance.id,
      isDefault: true,
      byKeyDown: true,
      byKeyUp: true,
    ),
    //--key event
    ShortcutConfigBean.fromKey(
      .delete,
      id: CanvasIntentActions.deleteSelectedElement.id,
      isDefault: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowUp,
      id: CanvasIntentActions.moveElementUp.id,
      isDefault: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowDown,
      id: CanvasIntentActions.moveElementDown.id,
      isDefault: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowLeft,
      id: CanvasIntentActions.moveElementLeft.id,
      isDefault: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowRight,
      id: CanvasIntentActions.moveElementRight.id,
      isDefault: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowUp,
      id: CanvasIntentActions.moveFastElementUp.id,
      isDefault: true,
      control: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowDown,
      id: CanvasIntentActions.moveFastElementDown.id,
      isDefault: true,
      control: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowLeft,
      id: CanvasIntentActions.moveFastElementLeft.id,
      isDefault: true,
      control: true,
    ),
    ShortcutConfigBean.fromKey(
      .arrowRight,
      id: CanvasIntentActions.moveFastElementRight.id,
      isDefault: true,
      control: true,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.undo.id,
      .keyZ,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.redo.id,
      .keyZ,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
      shift: true,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.copyElement.id,
      .keyC,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.pasteElement.id,
      .keyV,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.selectAllElement.id,
      .keyA,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.zoomIn.id,
      .equal,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.zoomOut.id,
      .minus,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.groupElement.id,
      .keyG,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
    ),
    ShortcutConfigBean.fromKey(
      id: CanvasIntentActions.ungroupElement.id,
      .keyG,
      isDefault: true,
      meta: isMacOS,
      control: !isMacOS,
      shift: true,
    ),
  ];

  /// 注册画布所有快捷方式意图
  static void registerCanvasShortcutIntents(
    ShortcutConfigManager? shortcutConfigManager,
  ) {
    if (shortcutConfigManager == null) {
      return;
    }
    shortcutConfigManager
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.dragCanvas.id,
          labelResKey: CanvasIntentActions.dragCanvas.resKey,
          label: CanvasIntentActions.dragCanvas.des,
          action: (ctx, event, host, data) {
            if (event != null && host is CanvasDelegate) {
              if (event.isKeyDown) {
                host.updateCanvasStyleModeChanged(CanvasStyleMode.dragMode);
                //host.addCursorStyle("drag", SystemMouseCursors.click);
              } else if (event.isKeyUp) {
                host.updateCanvasStyleModeChanged(null);
                //host.removeCursorStyle("drag", SystemMouseCursors.click);
              }
              host.refresh();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.scaleCanvas.id,
          labelResKey: CanvasIntentActions.scaleCanvas.resKey,
          label: CanvasIntentActions.scaleCanvas.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              //no op
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.measureDistance.id,
          labelResKey: CanvasIntentActions.measureDistance.resKey,
          label: CanvasIntentActions.measureDistance.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              //no op
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.ignoreLocalRatio.id,
          labelResKey: CanvasIntentActions.ignoreLocalRatio.resKey,
          label: CanvasIntentActions.ignoreLocalRatio.des,
          action: (ctx, event, host, data) {
            if (event != null && host is CanvasDelegate) {
              final lockControl = host
                  .canvasElementManager
                  .canvasElementControlManager
                  .lockControl;
              if (event.isKeyDown) {
                lockControl.setIgnoreLockRatio(true);
              } else if (event.isKeyUp) {
                lockControl.setIgnoreLockRatio(false);
              }
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.ignoreSmartAdsorption.id,
          labelResKey: CanvasIntentActions.ignoreSmartAdsorption.resKey,
          label: CanvasIntentActions.ignoreSmartAdsorption.des,
          action: (ctx, event, host, data) {
            if (event != null && host is CanvasDelegate) {
              //no op
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveElementUp.id,
          labelResKey: CanvasIntentActions.moveElementUp.resKey,
          label: CanvasIntentActions.moveElementUp.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.up);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveElementDown.id,
          labelResKey: CanvasIntentActions.moveElementDown.resKey,
          label: CanvasIntentActions.moveElementDown.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.down);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveElementLeft.id,
          labelResKey: CanvasIntentActions.moveElementLeft.resKey,
          label: CanvasIntentActions.moveElementLeft.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.left);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveElementRight.id,
          labelResKey: CanvasIntentActions.moveElementRight.resKey,
          label: CanvasIntentActions.moveElementRight.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.right);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveFastElementUp.id,
          labelResKey: CanvasIntentActions.moveFastElementUp.resKey,
          label: CanvasIntentActions.moveFastElementUp.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.up, fast: true);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveFastElementDown.id,
          labelResKey: CanvasIntentActions.moveFastElementDown.resKey,
          label: CanvasIntentActions.moveFastElementDown.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.down, fast: true);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveFastElementLeft.id,
          labelResKey: CanvasIntentActions.moveFastElementLeft.resKey,
          label: CanvasIntentActions.moveFastElementLeft.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.left, fast: true);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.moveFastElementRight.id,
          labelResKey: CanvasIntentActions.moveFastElementRight.resKey,
          label: CanvasIntentActions.moveFastElementRight.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.moveElement(.right, fast: true);
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.copyElement.id,
          labelResKey: CanvasIntentActions.copyElement.resKey,
          label: CanvasIntentActions.copyElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              return host.canvasKeyManager.copySelectedElement()
                  ? .handled
                  : .ignored;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.pasteElement.id,
          labelResKey: CanvasIntentActions.pasteElement.resKey,
          label: CanvasIntentActions.pasteElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              return host.canvasKeyManager.pasteSelectedElement()
                  ? .handled
                  : .ignored;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.selectAllElement.id,
          labelResKey: CanvasIntentActions.selectAllElement.resKey,
          label: CanvasIntentActions.selectAllElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.selectAllElement();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.deleteSelectedElement.id,
          labelResKey: CanvasIntentActions.deleteSelectedElement.resKey,
          label: CanvasIntentActions.deleteSelectedElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.deleteSelectedElement();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.undo.id,
          labelResKey: CanvasIntentActions.undo.resKey,
          label: CanvasIntentActions.undo.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.undo();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.redo.id,
          labelResKey: CanvasIntentActions.redo.resKey,
          label: CanvasIntentActions.redo.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.redo();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.zoomIn.id,
          labelResKey: CanvasIntentActions.zoomIn.resKey,
          label: CanvasIntentActions.zoomIn.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.zoomIn();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.zoomOut.id,
          labelResKey: CanvasIntentActions.zoomOut.resKey,
          label: CanvasIntentActions.zoomOut.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.zoomOut();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.groupElement.id,
          labelResKey: CanvasIntentActions.groupElement.resKey,
          label: CanvasIntentActions.groupElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.groupSelectedElement();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
      ..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.ungroupElement.id,
          labelResKey: CanvasIntentActions.ungroupElement.resKey,
          label: CanvasIntentActions.ungroupElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              host.canvasKeyManager.ungroupSelectedElement();
              return .handled;
            }
            return .ignored;
          },
        ),
      )
    /*..registerShortcutIntent(
        ShortcutIntentBean(
          id: CanvasIntentActions.deleteSelectedElement.id,
          labelResKey: CanvasIntentActions.deleteSelectedElement.resKey,
          label: CanvasIntentActions.deleteSelectedElement.des,
          action: (ctx, event, host, data) {
            if (host is CanvasDelegate) {
              return .handled;
            }
            return .ignored;
          },
        ),
      )*/
    ;
  }
}
