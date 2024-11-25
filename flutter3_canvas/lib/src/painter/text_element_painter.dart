part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/19
///
/// 文本绘制元素对象
class TextElementPainter extends ElementPainter {
  /// 当前绘制文本的对象
  BaseTextPainter? textPainter;

  //--get--

  /// 是否是矢量文本元素
  bool get isVectorTextElement => textPainter?.useVectorText == true;

  /// 矢量单字符文本对应的[Path]数据, 此时的[Path]还未进行
  /// [ElementPainter.transformElementOperatePath]
  List<Path> get vectorCharPathList {
    final result = <Path>[];
    final painter = textPainter;
    if (painter != null) {
      if (painter is SingleCharTextPainter) {
        final list = painter.charPainterList;
        if (list != null) {
          for (final line in list) {
            for (final char in line) {
              if (char is CharPathPainter) {
                final path = char.outputPath;
                if (path != null) {
                  result.add(path);
                }
              }
            }
          }
        }
      }
    }
    return result;
  }

  /// 进行了矩阵变换后的[vectorCharPathList]路径数据
  @override
  List<Path> get elementOutputPathList {
    if (isVectorTextElement) {
      return transformElementOperatePathList(vectorCharPathList) ?? [];
    } else {
      return super.elementOutputPathList;
    }
  }

  TextElementPainter() {
    debug = false;
  }

  /// 使用一个文本初始化[textPainter]对象,
  /// 并确认[TextElementPainter]元素的大小, 位置默认是0,0
  /// [onInitTextPainter] 回调给外部设置属性
  @initialize
  void initElementFromText(
    String? text, {
    void Function(BaseTextPainter textPainter)? onInitTextPainter,
  }) {
    final textPainter = NormalTextPainter()
      ..debugPaintBounds = debug
      ..text = text;
    onInitTextPainter?.call(textPainter);
    textPainter.initPainter();
    this.textPainter = textPainter;
    final size = textPainter.painterBounds;
    updatePaintProperty(
      PaintProperty()
        ..width = size.width
        ..height = size.height,
      notify: false,
    );
    //paintTextPainter = textPainter;
  }

  /// 绘制前, 更新文本颜色
  @override
  void onPaintingSelfBefore(Canvas canvas, PaintMeta paintMeta) {
    super.onPaintingSelfBefore(canvas, paintMeta);
    onSelfUpdateTextPainter();
  }

  /// 绘制前, 更新文本颜色
  /// [onPaintingSelfBefore]
  @overridePoint
  void onSelfUpdateTextPainter() {
    textPainter?.updateTextProperty(textColor: paint.color);
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    paintItTextPainter(canvas, paintMeta, textPainter);
    super.onPaintingSelf(canvas, paintMeta);
  }
}
