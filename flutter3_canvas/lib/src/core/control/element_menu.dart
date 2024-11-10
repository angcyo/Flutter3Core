part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/30
///
/// 元素菜单, 显示在选中元素上方
/// [CanvasElementControlManager]的成员
class ElementMenuControl
    with
        CanvasComponentMixin,
        IHandleEventMixin,
        CanvasElementControlManagerMixin {
  /// 画布元素控制器
  @override
  final CanvasElementControlManager canvasElementControlManager;

  ElementMenuControl(this.canvasElementControlManager);

  /// 菜单的padding
  EdgeInsets get menuPadding => canvasStyle.menuPadding ?? EdgeInsets.zero;

  /// 菜单的margin
  EdgeInsets get menuMargin => canvasStyle.menuMargin ?? EdgeInsets.zero;

  /// 创建元素菜单的回调
  List<ElementMenu>? Function(
    ElementMenuControl menuControl,
    List<ElementPainter>? children,
  )? onCreateElementMenuAction;

  /// 菜单的偏移量
  @dp
  double offset = kS;

  /// 是否忽略菜单的绘制和手势
  /// [needHandleElementMenu]
  bool ignoreMenuHandle = false;

  //--

  /// 菜单列表
  final List<ElementMenu> elementMenuList = [];

  //region --core--

  /// 是否需要处理元素菜单
  /// 绘制;
  /// 手势;
  bool needHandleElementMenu() =>
      !canvasElementControlManager.isPointerDownElement /*未在移动元素*/ &&
      canvasElementControlManager
          .elementMenuControl.isCanvasComponentEnable /*组件激活*/ &&
      canvasElementControlManager.isSelectedElement /*选中了元素*/ &&
      canvasElementControlManager.elementSelectComponent
          .isElementSupportControl(ControlTypeEnum.menu) /*支持菜单操作*/ &&
      !ignoreMenuHandle;

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
        _triangleAnchor.dx - canvasStyle.menuTriangleWidth / 2,
        _triangleAnchor.dy,
        () {
          _paintTriangle(canvas);
        },
      );
    }
  }

  /// 手势按下的菜单
  ElementMenu? _touchMenu;

  /// 按下的位置
  @viewCoordinate
  Offset? _touchPosition;

  /// [CanvasElementManager.handleElementEvent]->
  /// [CanvasElementControlManager.handleEvent]驱动, 可以拦截底部控制点的事件
  /// @return true 拦截事件
  @entryPoint
  bool handleMenuEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event.isTouchEvent) {
      bool handled = false;
      if (event.isPointerDown) {
        final localPosition = event.localPosition;
        _touchPosition = localPosition;
        for (final menu in elementMenuList) {
          if (menu._menuBounds?.contains(event.localPosition) == true) {
            _touchMenu = menu;
            canvasDelegate.refresh();
            break;
          }
        }
      } else if (event.isPointerUp) {
        if (!event.isMoveExceed(_touchPosition)) {
          _touchMenu?.onTap?.call();
          if (_touchMenu != null) {
            canvasDelegate.dispatchTapMenu(_touchMenu!);
          }
        }
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
  /// [anchorPainter] 菜单要显示的锚点元素, 通常是[ElementSelectComponent]
  /// [children] 选中的子元素集合
  /// [CanvasElementControlManager.onSelfSelectElementChanged]驱动
  @callPoint
  void onCanvasSelectElementChanged(
    ElementPainter anchorPainter,
    List<ElementPainter>? children,
  ) {
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

  /// 三角形的中心锚点位置
  @viewCoordinate
  Offset _triangleAnchor = Offset.zero;

  /// 执行菜单布局
  /// [bounds] 选中的元素边界
  void _performMenuLayout(@sceneCoordinate Rect bounds) {
    if (elementMenuList.isEmpty) {
      _menuBounds = null;
      return;
    }

    @viewCoordinate
    final paintBounds = canvasViewBox.paintBounds;
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
    //debugger();
    double left = clamp(
      center.dx - allWidth / 2,
      menuMargin.left + canvasStyle.yAxisWidth,
      paintBounds.right - allWidth - menuMargin.right,
    );
    double top =
        viewBounds.top - canvasStyle.menuTriangleHeight - maxHeight - offset;

    //菜单整体的边界
    _menuBounds = Rect.fromLTWH(left, top, allWidth, maxHeight);

    //三角形锚点
    _triangleAnchor = Offset(
      clamp(
        center.dx,
        _menuBounds!.left +
            canvasStyle.menuTriangleWidth / 2 +
            canvasStyle.menuRadius,
        _menuBounds!.right -
            canvasStyle.menuTriangleWidth / 2 -
            canvasStyle.menuRadius,
      ),
      _menuBounds!.bottom,
    );

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
  /// 菜单的标签标签
  @flagProperty
  final String? tag;

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
    this.tag,
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
    this.tag,
    this.size = const Size(30, 30),
    this.padding = const EdgeInsets.all(kS),
    this.pictureTintColor = Colors.white,
    this.painterFn,
    this.onTap,
  }) : pictureInfoFuture = loadAssetSvgPicture(key);
}
