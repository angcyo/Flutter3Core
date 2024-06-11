part of '../flutter3_scanner.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/11
///
/// 简单的二维码扫描界面
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

  /// 扫码成功后,是否自动关闭页面
  final bool autoPop;

  /// 是否显示闪光灯按钮
  final bool showFlashlightButton;

  /// 是否显示相册按钮
  final bool showAnalyzeImageButton;

  /// 双击放大的倍数[0~1]
  final double doubleZoomFactor;

  const SingleCodeScannerPage({
    super.key,
    this.scanFormats = const [BarcodeFormat.qrCode],
    this.torchEnabled = false,
    this.showScanWindow = true,
    this.onCodeScannerCallback,
    this.autoPop = true,
    this.showFlashlightButton = true,
    this.showAnalyzeImageButton = true,
    this.doubleZoomFactor = 0.5,
    this.scanWindowSize = const Size(200, 200),
  });

  @override
  State<SingleCodeScannerPage> createState() => _SingleCodeScannerPageState();
}

class _SingleCodeScannerPageState extends State<SingleCodeScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: widget.scanFormats,
    torchEnabled: widget.torchEnabled,
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
      Feedback.forLongPress(buildContext!);
      widget.onCodeScannerCallback?.call(list!);
      if (widget.autoPop) {
        _isDisposed = true;
        postFrameCallback((_) {
          buildContext?.pop(list);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  Widget _buildBarcodeOverlay() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: controller.barcodes,
          builder: (context, snapshot) {
            final BarcodeCapture? barcodeCapture = snapshot.data;

            // No barcode.
            if (barcodeCapture == null || barcodeCapture.barcodes.isEmpty) {
              return const SizedBox();
            }

            final scannedBarcode = barcodeCapture.barcodes.first;

            // No barcode corners, or size, or no camera preview size.
            if (scannedBarcode.corners.isEmpty ||
                value.size.isEmpty ||
                barcodeCapture.size.isEmpty) {
              return const SizedBox();
            }

            return CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: BarcodeOverlay(
                barcodeCorners: scannedBarcode.corners,
                barcodeSize: barcodeCapture.size,
                boxFit: BoxFit.contain,
                cameraPreviewSize: value.size,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: ScannerOverlay(scanWindow: scanWindowRect),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    final Rect? scanWindowRect = widget.showScanWindow
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
            scanWindow: scanWindowRect,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
            fit: BoxFit.cover,
          ),
          _buildBarcodeOverlay(),
          if (scanWindowRect != null) _buildScanWindow(scanWindowRect),
          const SizedBox(width: double.infinity, height: double.infinity)
              .doubleClick(() {
            //双击放大/缩小
            if (_zoomFactor == 0.0) {
              _zoomFactor = widget.doubleZoomFactor;
            } else {
              _zoomFactor = 0.0;
            }
            controller.setZoomScale(_zoomFactor);
          }),
          if (widget.showFlashlightButton)
            ToggleFlashlightButton(controller: controller)
                .paddingAll(kBottomNavigationBarHeight)
                .align(Alignment.bottomCenter),
          if (widget.showAnalyzeImageButton)
            AnalyzeImageFromGalleryButton(
              controller: controller,
              onCodeScannerCallback: (result) {
                _handleStringResult(result);
              },
            )
                .paddingOnly(right: kX, bottom: kBottomNavigationBarHeight)
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
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
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
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

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

/// ?
class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty ||
        barcodeSize.isEmpty ||
        cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// 开关闪光灯
class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_auto),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flashlight_off),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flashlight_on),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const Icon(
              Icons.no_flash,
              color: Colors.grey,
            );
        }
      },
    );
  }
}

/// 从相册中选择图片, 分析二维码
class AnalyzeImageFromGalleryButton extends StatelessWidget {
  /// 扫描结果回调
  final OnCodeScannerCallback? onCodeScannerCallback;

  const AnalyzeImageFromGalleryButton({
    required this.controller,
    super.key,
    this.onCodeScannerCallback,
  });

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.image),
      iconSize: 32.0,
      onPressed: () async {
        final ImagePicker picker = ImagePicker();

        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image == null) {
          return;
        }

        final BarcodeCapture? barcodes = await controller.analyzeImage(
          image.path,
        );

        if (!context.mounted) {
          return;
        }

        //result
        final list = barcodes?.barcodes
                .map((e) => e.displayValue)
                .filterNull<String>()
                .toList() ??
            [];
        if (!isNil(list)) {
          Feedback.forLongPress(context);
          onCodeScannerCallback?.call(list);
        }
      },
    );
  }
}

/// 开始/停止扫描
class StartStopMobileScannerButton extends StatelessWidget {
  const StartStopMobileScannerButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return IconButton(
            color: Colors.white,
            icon: const Icon(Icons.play_arrow),
            iconSize: 32.0,
            onPressed: () async {
              await controller.start();
            },
          );
        }

        return IconButton(
          color: Colors.white,
          icon: const Icon(Icons.stop),
          iconSize: 32.0,
          onPressed: () async {
            await controller.stop();
          },
        );
      },
    );
  }
}

/// 切换摄像头
class SwitchCameraButton extends StatelessWidget {
  const SwitchCameraButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final int? availableCameras = state.availableCameras;

        if (availableCameras != null && availableCameras < 2) {
          return const SizedBox.shrink();
        }

        final Widget icon;

        switch (state.cameraDirection) {
          case CameraFacing.front:
            icon = const Icon(Icons.camera_front);
          case CameraFacing.back:
            icon = const Icon(Icons.camera_rear);
        }

        return IconButton(
          iconSize: 32.0,
          icon: icon,
          onPressed: () async {
            await controller.switchCamera();
          },
        );
      },
    );
  }
}
