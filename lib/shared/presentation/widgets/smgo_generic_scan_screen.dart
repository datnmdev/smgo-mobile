import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smgo/core/resources/app_strings.dart';

/// Định nghĩa kiểu dữ liệu callback (Cho phép T? nullable)
typedef ScanHandlerCallback<T> = Future<T?> Function(String rawValue);
typedef ScanResultBuilder<T> = Widget Function(BuildContext context, T? data);
typedef ScanCompleteCallback<T> = void Function(BuildContext context, T? data);

class SmgoGenericScanScreen<T> extends StatefulWidget {
  final String title;
  final ScanHandlerCallback<T> onHandleScan;
  final ScanResultBuilder<T> itemBuilder;
  final ScanCompleteCallback<T>? onComplete;

  // Kích thước khung quét cố định (250x250)
  static const double scanAreaSize = 250.0;

  const SmgoGenericScanScreen({
    super.key,
    required this.title,
    required this.onHandleScan,
    required this.itemBuilder,
    this.onComplete,
  });

  @override
  State<SmgoGenericScanScreen<T>> createState() =>
      _SmgoGenericScanScreenState<T>();
}

class _SmgoGenericScanScreenState<T> extends State<SmgoGenericScanScreen<T>> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;
  T? _analyzedData;
  bool _torchEnabled = false;
  Rect? _scanWindowRect;
  bool _isBottomSheetOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm xử lý khi quét được mã (Vẫn mở ngăn kéo dù tìm thấy hoặc không tìm thấy)
  Future<void> _onDetect(BarcodeCapture capture) async {
    // 🟢 Chặn nếu đang xử lý, ngăn kéo đang mở, hoặc chưa có khung quét
    if (_isProcessing || _isBottomSheetOpen || _scanWindowRect == null) {
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        setState(() {
          _isProcessing = true;
          _isBottomSheetOpen = true; // 🟢 Bật cờ khóa không cho quét tiếp
        });

        try {
          T? result = await widget.onHandleScan(rawValue);

          setState(() {
            _analyzedData = result;
            _isProcessing = false;
          });
          if (widget.onComplete != null) {
            widget.onComplete!(context, result);
          }
          _showBottomSheet(result);
        } catch (e) {
          setState(() {
            _isProcessing = false;
            _isBottomSheetOpen = false; // 🟢 Mở lại khóa nếu lỗi xảy ra
          });
        }
        break;
      }
    }
  }

  // Hiển thị ngăn kéo kết quả, có thêm hiệu ứng đổ bóng xanh phía trên
  void _showBottomSheet(T? resultData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withAlpha((0.4 * 255).round()),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF006837),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.gSSAnalysisResultTitle.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Expanded(child: widget.itemBuilder(context, resultData)),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // 🟢 Khi vuốt đóng ngăn kéo xuống, mở khóa quét lại và reset dữ liệu
      setState(() {
        _analyzedData = null;
        _isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006837),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = Rect.fromCenter(
            center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            width: SmgoGenericScanScreen.scanAreaSize,
            height: SmgoGenericScanScreen.scanAreaSize,
          );

          if (_scanWindowRect != scanWindow) {
            _scanWindowRect = scanWindow;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _controller.updateScanWindow(scanWindow);
              }
            });
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                scanWindow: scanWindow,
              ),

              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha((0.5 * 255).round()),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: SmgoGenericScanScreen.scanAreaSize,
                        height: SmgoGenericScanScreen.scanAreaSize,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Khung định vị góc xanh & Hiệu ứng tia quét
              Center(
                child: SizedBox(
                  width: SmgoGenericScanScreen.scanAreaSize,
                  height: SmgoGenericScanScreen.scanAreaSize,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      const _ScannerLaserAnimation(
                        size: SmgoGenericScanScreen.scanAreaSize,
                      ),
                      CustomPaint(
                        size: const Size(
                          SmgoGenericScanScreen.scanAreaSize,
                          SmgoGenericScanScreen.scanAreaSize,
                        ),
                        painter: ScannerOverlayPainter(),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(bottom: 40, child: _buildFlashButton()),

              Positioned(
                bottom: 100,
                child: Text(
                  AppStrings.gSSScanInstruction.tr(),
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              if (_isProcessing)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlashButton() {
    return GestureDetector(
      onTap: () async {
        await _controller.toggleTorch();
        setState(() => _torchEnabled = !_torchEnabled);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.6 * 255).round()),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _torchEnabled ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final double cornerLength = 24;

    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerLaserAnimation extends StatefulWidget {
  final double size;
  const _ScannerLaserAnimation({required this.size});

  @override
  State<_ScannerLaserAnimation> createState() => _ScannerLaserAnimationState();
}

class _ScannerLaserAnimationState extends State<_ScannerLaserAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: _animationController.value * (widget.size - 20),
          child: Container(
            width: widget.size - 16,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withAlpha((0.8 * 255).round()),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
