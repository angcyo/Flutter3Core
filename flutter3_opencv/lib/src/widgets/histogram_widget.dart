part of "../../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
/// 直方图绘制
class HistogramWidget extends LeafRenderObjectWidget {
  /// 直方图数据
  final List<List<double>>? histData;

  const HistogramWidget({super.key, this.histData});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return HistogramRenderBox()..histData = histData;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    HistogramRenderBox renderObject,
  ) {
    renderObject.histData = histData;
  }
}

class HistogramRenderBox extends RenderBox {
  /// 直方图数据
  /// - 灰度值从 0~255 每个灰度值对应的像素个数
  @configProperty
  List<List<double>>? _histData;

  List<List<double>>? get histData => _histData;

  set histData(List<List<double>>? value) {
    if (_histData == value) return;
    _histData = value;
    _maxHistSize = 0;
    _sumHistSize = 0;
    if (value != null) {
      for (final hist in value) {
        _sumHistSize += hist.sum;
        _maxHistSize = max(_maxHistSize, hist.sum);
      }
    }
    markNeedsPaint();
  }

  /// 最大柱子的大小
  @tempFlag
  double _maxHistSize = 0;

  /// 所有柱子数值的和
  @tempFlag
  double _sumHistSize = 0;

  @override
  void performLayout() {
    //debugger();
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //super.paint(context, offset);
    final canvas = context.canvas;
    final histData = this.histData;
    if (histData != null) {
      //final fontSize = kDefaultFontSize;
      //canvas.drawText("text")

      final width = size.width;
      final height = size.height;

      final binsCount = histData.length;
      final binsWidth = width / binsCount;

      final bottom = offset.dy + height;
      double left = offset.dx;

      //第一个有数据的灰度像素值
      int? firstGrayPixelValue;
      //最后一个有数据的灰度像素值
      int? lastGrayPixelValue;
      for (final (index, bins) in histData.indexed) {
        final sum = bins.sum;
        if (sum > 0) {
          firstGrayPixelValue ??= index;
          lastGrayPixelValue = index;
        }
        final binsHeight = sum / _maxHistSize * height;
        canvas.drawRect(
          Rect.fromLTWH(left, bottom - binsHeight, binsWidth, binsHeight),
          Paint()
            ..color = Colors.black
            ..style = .fill,
        );
        left += binsWidth;
      }

      //MARK: - gray range
      canvas.drawText(
        "$firstGrayPixelValue~$lastGrayPixelValue / ${_sumHistSize.round()}",
        textColor: Colors.grey,
        bounds: size.toRect(offset),
        alignment: .topRight,
      );
    }
    //debugger();
    //debugPaintBoxBounds(context, offset);
  }
}
