import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shipgo/core/resources/app_colors.dart';

// Tông màu chủ đạo theo UI mẫu
const Color kPrimaryGreen = AppColors.primary;
const Color kLightGreen = Color(0xFFE8F5E9);

class AiOcrScanButton<T> extends StatefulWidget {
  final Future<String> Function(String prompt) llmProcessor;
  final ValueChanged<T> onCompleted;
  final String Function(String ocrText) promptBuilder;
  final T Function(String llmOutput) parser;
  final Widget Function(BuildContext context, T data)? previewBuilder;

  // Tham số mới giúp tùy biến hoàn toàn diện mạo nút từ bên ngoài
  final Widget Function(BuildContext context, VoidCallback onPressed)? builder;

  // Các tham số cũ giữ lại làm fallback khi không dùng builder riêng
  final String buttonText;
  final IconData buttonIcon;
  final String dialogTitle;
  final bool showPreviewDialog;

  const AiOcrScanButton({
    super.key,
    required this.llmProcessor,
    required this.onCompleted,
    required this.promptBuilder,
    required this.parser,
    this.previewBuilder,
    this.builder, // Khai báo tham số mới
    this.buttonText = 'Quét dữ liệu',
    this.buttonIcon = Icons.camera_alt_outlined,
    this.dialogTitle = 'Kết Quả Phân Tích',
    this.showPreviewDialog = true,
  });

  @override
  State<AiOcrScanButton<T>> createState() => _AiOcrScanButtonState<T>();
}

class _AiOcrScanButtonState<T> extends State<AiOcrScanButton<T>> {
  Future<void> _openCameraScreen() async {
    // Xin quyền truy cập máy ảnh
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền truy cập máy ảnh.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    if (!mounted) return;

    // Chuyển sang màn hình Camera quét trực tiếp
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OcrCameraScannerView<T>(
          camera: cameras.first,
          llmProcessor: widget.llmProcessor,
          promptBuilder: widget.promptBuilder,
          parser: widget.parser,
          previewBuilder: widget.previewBuilder,
          onCompleted: widget.onCompleted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nếu bên ngoài truyền `builder` vào thì ưu tiên hiển thị giao diện tùy chỉnh
    if (widget.builder != null) {
      return widget.builder!(context, _openCameraScreen);
    }

    // Ngược lại, sử dụng giao diện mặc định cũ
    return OutlinedButton.icon(
      onPressed: _openCameraScreen,
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryGreen,
        side: const BorderSide(color: kPrimaryGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(widget.buttonIcon, color: kPrimaryGreen),
      label: Text(
        widget.buttonText,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: kPrimaryGreen,
        ),
      ),
    );
  }
}

class OcrCameraScannerView<T> extends StatefulWidget {
  final CameraDescription camera;
  final Future<String> Function(String prompt) llmProcessor;
  final String Function(String ocrText) promptBuilder;
  final T Function(String llmOutput) parser;
  final Widget Function(BuildContext context, T data)? previewBuilder;
  final ValueChanged<T> onCompleted;

  const OcrCameraScannerView({
    super.key,
    required this.camera,
    required this.llmProcessor,
    required this.promptBuilder,
    required this.parser,
    required this.onCompleted,
    this.previewBuilder,
  });

  @override
  State<OcrCameraScannerView<T>> createState() =>
      _OcrCameraScannerViewState<T>();
}

class _OcrCameraScannerViewState<T> extends State<OcrCameraScannerView<T>> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _isProcessing = false;
  String _stepStatus = '';

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _updateStatus(String status) {
    if (mounted) setState(() => _stepStatus = status);
  }

  Future<void> _executePipeline() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Chụp ảnh từ CameraController
      _updateStatus('Đang chụp ảnh...');
      final photo = await _cameraController.takePicture();

      // 2. OCR ML Kit
      _updateStatus('Đang bóc tách chữ từ ảnh...');
      final inputImage = InputImage.fromFilePath(photo.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.trim().isEmpty) {
        throw 'Không tìm thấy văn bản nào trong ảnh!';
      }

      // 3. Phân tích qua LLM
      _updateStatus('Mô hình AI đang xử lý...');
      final prompt = widget.promptBuilder(recognizedText.text);
      final rawResponse = await widget.llmProcessor(prompt);
      final T parsedResult = widget.parser(rawResponse);

      print(parsedResult);

      // 4. Hiển thị Ngăn kéo (BottomSheet) ngay tại màn hình Camera
      if (mounted) {
        _showResultBottomSheet(parsedResult);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _stepStatus = '';
        });
      }
    }
  }

  void _showResultBottomSheet(T data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh nắm kéo ngăn kéo (YouTube style handle bar)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: kPrimaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Kết quả phân tích',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Nội dung hiển thị thông tin
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: SingleChildScrollView(
                  child: widget.previewBuilder != null
                      ? widget.previewBuilder!(ctx, data)
                      : _buildDefaultPreviewData(data),
                ),
              ),

              const SizedBox(height: 20),

              // Hai nút thao tác: Quét lại & Xác nhận
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                      ), // Đóng ngăn kéo, giữ nguyên camera
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Quét lại',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Đóng ngăn kéo
                        Navigator.pop(context); // Thoát màn hình camera
                        widget.onCompleted(data); // Trả kết quả ra callback
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultPreviewData(T data) {
    if (data is Map) {
      return Column(
        children: [
          _buildInfoRow('Mã vận đơn', data['orderCode'] ?? '---'),
          _buildInfoRow('Tên sản phẩm', data['orderName'] ?? '---'),
          _buildInfoRow('Tên người nhận', data['contactName'] ?? '---'),
          _buildInfoRow('Số điện thoại', data['contactPhone'] ?? '---'),
          _buildInfoRow('Địa chỉ nhận', data['address'] ?? '---', isLast: true),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(data.toString(), style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quét thông tin đơn hàng',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryGreen),
            );
          }

          return Stack(
            children: [
              // 1. Camera Viewport
              Positioned.fill(child: CameraPreview(_cameraController)),

              // 2. Thông báo các bước xử lý (Overlay Status)
              if (_isProcessing)
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.8 * 255).round()),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _stepStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Nút chụp ảnh
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTap: _isProcessing ? null : _executePipeline,
                    child: Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isProcessing ? Colors.grey : kPrimaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
