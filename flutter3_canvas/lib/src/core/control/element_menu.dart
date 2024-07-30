part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/30
///
/// 元素菜单, 显示在选中元素上方
/// [CanvasElementControlManager]的成员
class ElementMenuControl with CanvasComponentMixin, IHandleEventMixin {
  /// 画布元素控制器
  final CanvasElementControlManager canvasElementControlManager;

  CanvasDelegate get canvasDelegate =>
      canvasElementControlManager.canvasDelegate;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  ElementMenuControl(this.canvasElementControlManager);

  /// 菜单的padding
  EdgeInsets get menuPadding => canvasStyle.menuPadding ?? EdgeInsets.zero;

  /// 菜单的margin
  EdgeInsets get menuMargin => canvasStyle.menuMargin ?? EdgeInsets.zero;

  /// 创建元素菜单的回调
  List<ElementMenu> Function(
          ElementMenuControl menuControl, List<ElementPainter>? children)?
      onCreateElementMenuAction;

  //--

  /// 菜单列表
  final List<ElementMenu> elementMenuList = [];

  //region --core--

  /// [CanvasElementControlManager.paint]驱动, 无法绘制在坐标轴上
  /// [CanvasElementManager.paintElements]驱动, 可以绘制在坐标轴上
  @entryPoint
  void paintMenu(Canvas canvas, PaintMeta paintMeta) {
    final menuBounds = _menuBounds;
    if (menuBounds != null) {
      canvas.drawRRect(menuBounds.toRRect(canvasStyle.menuRadius),
          Paint()..color = canvasStyle.menuBgColor);

      //menu
      final lastIndex = elementMenuList.lastIndex;
      elementMenuList.forEachIndexed((index, menu) {
        final subMenuBounds = menu._menuBounds;
        if (subMenuBounds != null) {
          //按下时的背景提示
          if (_touchMenu == menu) {
            canvas.drawCircle(
                subMenuBounds.center,
                min(subMenuBounds.width, subMenuBounds.height) / 2 - kM,
                Paint()..color = Colors.white24);
          }
          if (menu.painterFn != null) {
            menu.painterFn!(canvas, subMenuBounds, false);
          }
          if (menu.pictureInfo != null) {
            canvas.drawPictureInRect(
              menu.pictureInfo?.picture,
              dst: subMenuBounds,
              pictureSize: menu.pictureInfo?.size,
              tintColor: menu.pictureTintColor,
              dstPadding: menu.padding,
            );
          }
          if (lastIndex != index) {
            //绘制分割线
            canvas.drawLine(
                Offset(subMenuBounds.right, subMenuBounds.top + kH),
                Offset(subMenuBounds.right, subMenuBounds.bottom - kH),
                Paint()
                  ..color = canvasStyle.menuLineColor
                  ..strokeWidth = 1);
          }
        }
      });
      //绘制三角形
      canvas.withTranslate(
        menuBounds.center.dx - canvasStyle.menuTriangleWidth / 2,
        menuBounds.bottom,
        () {
          _paintTriangle(canvas);
        },
      );
    }
  }

  /// 手势按下的菜单
  ElementMenu? _touchMenu;

  /// [CanvasElementManager.handleElementEvent]->
  /// [CanvasElementControlManager.handleEvent]驱动, 可以拦截底部控制点的事件
  /// @return true 拦截事件
  @entryPoint
  bool handleMenuEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event.isTouchEvent) {
      bool handled = false;
      if (event.isPointerDown) {
        for (final menu in elementMenuList) {
          if (menu._menuBounds?.contains(event.localPosition) == true) {
            _touchMenu = menu;
            canvasDelegate.refresh();
            break;
          }
        }
      } else if (event.isPointerUp) {
        _touchMenu?.onTap?.call();
      }
      handled = _touchMenu != null;
      if (event.isPointerFinish) {
        _touchMenu = null;
        canvasDelegate.refresh();
      }
      return handled;
    }
    return false;
  }

  //endregion --core--

  //region --paint--

  /// 绘制三角形
  void _paintTriangle(Canvas canvas) {
    final paint = Paint();
    final path = Path();
    paint.isAntiAlias = true;
    paint.color = canvasStyle.menuBgColor;
    Size size =
        Size(canvasStyle.menuTriangleWidth, canvasStyle.menuTriangleHeight);
    path.lineTo(size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.58, size.height * 1.05, size.width * 0.42,
        size.height * 1.05, size.width * 0.34, size.height * 0.86);
    path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width * 0.66, size.height * 0.86,
        size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.66, size.height * 0.86, size.width * 0.66,
        size.height * 0.86, size.width * 0.66, size.height * 0.86);
    canvas.drawPath(path, paint);
  }

  //endregion --paint--

  //region --menu--

  /// 当选中的元素改变时触发, 此时可以更新菜单
  /// [CanvasElementControlManager.onSelfSelectElementChanged]驱动
  @callPoint
  void onCanvasSelectElementChanged(
      ElementPainter anchorPainter, List<ElementPainter>? children) {
    if (onCreateElementMenuAction != null) {
      _menuBounds = null;
      elementMenuList.reset(onCreateElementMenuAction!(this, children));
      for (final menu in elementMenuList) {
        menu.pictureInfoFuture?.get((value, error) {
          if (value is PictureInfo) {
            menu.pictureInfo = value;
            canvasDelegate.refresh();
          }
        });
      }
      updateMenuLayoutBounds(anchorPainter);
    }
  }

  /// 更新菜单位置
  /// [CanvasElementControlManager.updateControlBounds]驱动
  @callPoint
  void updateMenuLayoutBounds(ElementPainter anchorPainter) {
    final bounds = anchorPainter.elementsBounds;
    if (bounds != null) {
      _performMenuLayout(bounds);
    }
  }

  /// 菜单的整体边界
  @viewCoordinate
  Rect? _menuBounds;

  /// 执行菜单布局
  /// [bounds] 选中的元素边界
  void _performMenuLayout(@sceneCoordinate Rect bounds) {
    if (elementMenuList.isEmpty) {
      _menuBounds = null;
      return;
    }

    @viewCoordinate
    final viewBounds = canvasViewBox.toViewRect(bounds);
    final center = viewBounds.center;

    //菜单最大的高度
    double maxHeight = 0;
    //整体的宽度
    double allWidth =
        elementMenuList.fold(menuPadding.horizontal, (previousValue, element) {
      maxHeight = max(
          maxHeight, element.size.height + (element.padding?.vertical ?? 0));
      return previousValue +
          element.size.width +
          (element.padding?.horizontal ?? 0);
    });
    maxHeight += menuPadding.vertical;

    //开始布局的位置
    double left = max(menuMargin.left, center.dx - allWidth / 2);
    double top = viewBounds.top - canvasStyle.menuTriangleHeight - maxHeight;

    //菜单整体的边界
    _menuBounds = Rect.fromLTWH(left, top, allWidth, maxHeight);

    //菜单项的边界
    for (final menu in elementMenuList) {
      final w = menu.size.width + (menu.padding?.horizontal ?? 0);
      final h = menu.size.height + (menu.padding?.vertical ?? 0);
      menu._menuBounds = Rect.fromLTWH(left, top + (maxHeight - h) / 2, w, h);
      left += w;
    }
  }

//endregion --menu--
}

/// [ElementMenuControl]中的菜单项
class ElementMenu {
  /// 菜单大小
  @viewCoordinate
  final Size size;

  /// 菜单的padding
  final EdgeInsets? padding;

  /// 菜单绘制的图片如果有
  PictureInfo? pictureInfo;

  /// 图片的tintColor
  final Color? pictureTintColor;

  /// 加载[pictureInfo]的[Future]
  final Future<PictureInfo?>? pictureInfoFuture;

  /// 菜单自定义的绘制方法
  @viewCoordinate
  final ControlPainterFn? painterFn;

  /// 菜单点击回调
  final VoidCallback? onTap;

  /// 计算出来的菜单边界
  @output
  Rect? _menuBounds;

  ElementMenu({
    this.size = const Size(30, 30),
    this.padding = const EdgeInsets.all(kS),
    this.pictureInfo,
    this.pictureTintColor = Colors.white,
    this.pictureInfoFuture,
    this.painterFn,
    this.onTap,
  });

  ElementMenu.fromSvg(
    String key, {
    this.size = const Size(30, 30),
    this.padding = const EdgeInsets.all(kS),
    this.pictureTintColor = Colors.white,
    this.painterFn,
    this.onTap,
  }) : pictureInfoFuture = loadAssetSvgPicture(key);
}
