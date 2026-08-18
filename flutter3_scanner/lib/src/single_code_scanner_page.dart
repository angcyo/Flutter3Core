part of '../flutter3_scanner.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/11
///

/// 扫描控制按钮的大小
const kScannerControlButtonSize = 32.0;

/// 扫描控制按钮的底部间距
const kScannerControlButtonBottom = 26.0;

/// 简单的二维码扫描界面
/// - [onCodeScannerCallback] 扫描结果回调
/// ```
/// buildContext?.pushWidget(SingleCodeScannerPage());
/// ```
/// @return 返回扫码结果, 可能包含多个
/// - [List<String>]
class SingleCodeScannerPage extends StatefulWidget {
  /// 扫描的格式, 默认[BarcodeFormat.qrCode]
  final List<BarcodeFormat> scanFormats;

  /// 是否启用手电筒
  final bool torchEnabled;

  /// 扫描结果回调
  final OnCodeScannerCallback? onCodeScannerCallback;

  //---

  /// 是否显示扫描窗口
  final bool showScanWindow;

  /// 扫描窗口大小
  final Size scanWindowSize;

  /// 是否使用扫描窗口覆盖层
  final bool useBarcodeOverlay;

  /// 扫码成功后,是否自动关闭页面
  final bool autoPop;

  /// 是否显示切换摄像头按钮
  final bool showSwitchCameraButton;

  /// 是否显示闪光灯按钮
  final bool showFlashlightButton;

  /// 是否显示相册按钮
  final bool showAnalyzeImageButton;

  /// 双击放大的倍数[0~1]
  final double doubleZoomFactor;

  //--

  /// 是否自动启动相机
  final bool autoStart;

  /// 相机距离太远时, 是否自动放大
  @PlatformFlag("Android")
  final bool autoZoom;

  /// 相机预览的缩放模式
  final BoxFit boxFit;

  const SingleCodeScannerPage({
    super.key,
    this.scanFormats = const [BarcodeFormat.qrCode],
    this.torchEnabled = false,
    this.showScanWindow = true,
    this.onCodeScannerCallback,
    this.autoPop = true,
    this.showSwitchCameraButton = false,
    this.showFlashlightButton = true,
    this.showAnalyzeImageButton = true,
    this.doubleZoomFactor = 0.5,
    this.scanWindowSize = const Size(200, 200),
    this.useBarcodeOverlay = false,
    this.autoStart = true,
    this.autoZoom = true,
    this.boxFit = .cover,
  });

  @override
  State<SingleCodeScannerPage> createState() => _SingleCodeScannerPageState();
}

class _SingleCodeScannerPageState extends State<SingleCodeScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: widget.scanFormats,
    //闪光灯
    torchEnabled: widget.torchEnabled,
    autoStart: widget.autoStart,
    //自动放大
    autoZoom: widget.autoZoom,
    /*returnImage: */
  );

  StreamSubscription<Object?>? _subscription;

  /// 是否已经释放
  bool _isDisposed = false;

  /// 缩放因子
  double _zoomFactor = 0.0;

  /// 处理扫描结果
  void _handleBarcode(BarcodeCapture barcodes) {
    if (!_isDisposed && mounted) {
      final list = barcodes.barcodes
          .map((e) => e.displayValue)
          .filterNull<String>()
          .toList();
      _handleStringResult(list);
    }
  }

  /// 处理字符串返回值
  void _handleStringResult(List<String>? list) {
    if (!isNil(list)) {
      assert(() {
        l.i("[${classHash()}]扫码结果->$list");
        return true;
      }());
      Feedback.forLongPress(buildContext!);
      if (widget.autoPop) {
        _isDisposed = true;
        postFrameCallback((_) {
          buildContext?.pop(result: list);
          widget.onCodeScannerCallback?.call(list!);
        });
      } else if (widget.onCodeScannerCallback == null) {
        toastMessage(list!.join("\n").text());
      } else {
        widget.onCodeScannerCallback?.call(list!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    if (!widget.autoStart) {
      controller.start().ignore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }
    switch (state) {
      case .detached:
      case .hidden:
      case .paused:
        return;
      case .resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);
        controller.start().ignore();
      case .inactive:
        _subscription?.cancel().ignore();
        _subscription = null;
        controller.stop().ignore();
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel().ignore();
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    final scanWindowRect = widget.showScanWindow
        ? Rect.fromCenter(
            center: MediaQuery.sizeOf(context).center(Offset.zero),
            width: widget.scanWindowSize.width,
            height: widget.scanWindowSize.height,
          )
        : null;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            //点击聚焦 @PlatformFlag("Android iOS")
            tapToFocus: true,
            scanWindow: scanWindowRect,
            errorBuilder: (context, error) {
              return ScannerErrorWidget(error: error);
            },
            fit: widget.boxFit,
            /*onDetect: (barcodes) {
              //debugger();
            },*/
          ),
          if (widget.useBarcodeOverlay /*|| isDebug*/ )
            // Needed for tapToFocus
            IgnorePointer(
              child: BarcodeOverlay(
                controller: controller,
                boxFit: widget.boxFit,
              ),
            ),
          if (scanWindowRect != null)
            IgnorePointer(
              child: ScanWindowOverlay(
                scanWindow: scanWindowRect,
                controller: controller,
              ),
            ),
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ).doubleClick(() {
            //双击放大/缩小
            if (_zoomFactor == 0.0) {
              _zoomFactor = widget.doubleZoomFactor;
            } else {
              _zoomFactor = 0.0;
            }
            controller.setZoomScale(_zoomFactor);
          }),
          //控制按钮
          if (widget.showSwitchCameraButton)
            SwitchCameraButton(controller: controller)
                .paddingOnly(left: kX, bottom: kScannerControlButtonBottom)
                .align(Alignment.bottomLeft),
          if (widget.showFlashlightButton)
            ToggleFlashlightButton(controller: controller)
                .paddingAll(kScannerControlButtonBottom)
                .align(Alignment.bottomCenter),
          if (widget.showAnalyzeImageButton)
            AnalyzeImageButton(
                  controller: controller,
                  onCodeScannerCallback: (result) {
                    _handleStringResult(result);
                  },
                )
                .paddingOnly(right: kX, bottom: kScannerControlButtonBottom)
                .align(Alignment.bottomRight),
        ],
      ),
    );
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scanning is unsupported on this device';
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(errorMessage, style: const TextStyle(color: Colors.white)),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// 扫描框
class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({required this.scanWindow, this.borderRadius = 12.0});

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: use `Offset.zero & size` instead of Rect.largest
    // we need to pass the size to the custom paint widget
    //final backgroundPath = Path()..addRect(Rect.largest);
    //final backgroundPath = Path()..addRect(const Rect.fromLTWH(0, 0, 600, 600));
    final backgroundPath = Path()..addRect(Offset.zero & size);

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill /*..blendMode = BlendMode.dstOut*/;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    //debugger();
    //canvas.drawRect(Rect.largest, backgroundPaint);
    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
