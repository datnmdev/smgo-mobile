import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AiOcrScanButton<T> extends StatefulWidget {
  /// Hàm callback xử lý suy luận LLM (nhận prompt -> trả về chuỗi kết quả)
  final Future<String> Function(String prompt) llmProcessor;

  /// Callback trả về kết quả kiểu T sau khi phân tích và người dùng xác nhận
  final ValueChanged<T> onCompleted;

  /// Hàm dựng Prompt dựa trên văn bản OCR thô
  final String Function(String ocrText) promptBuilder;

  /// Hàm parse kết quả chuỗi từ LLM ra đối tượng kiểu T
  final T Function(String llmOutput) parser;

  /// Custom Widget hiển thị nội dung xem trước trong Dialog (Tùy chọn)
  final Widget Function(BuildContext context, T data)? previewBuilder;

  /// Tùy chỉnh giao diện nút
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
    this.buttonText = 'Quét dữ liệu',
    this.buttonIcon = Icons.camera_alt_outlined,
    this.dialogTitle = 'Kết Quả Phân Tích',
    this.showPreviewDialog = true,
  });

  @override
  State<AiOcrScanButton<T>> createState() => _AiOcrScanButtonState<T>();
}

class _AiOcrScanButtonState<T> extends State<AiOcrScanButton<T>> {
  bool _isProcessing = false;
  String _stepStatus = '';

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _executePipeline() async {
    _updateStatus('Đang xin quyền máy ảnh...');
    setState(() => _isProcessing = true);

    try {
      // 1. Xin quyền
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showErrorSnackBar('Cần cấp quyền truy cập máy ảnh.');
        return;
      }

      // 2. Chụp ảnh
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo == null) return;

      // 3. OCR ML Kit
      _updateStatus('Đang bóc tách chữ từ ảnh...');
      final inputImage = InputImage.fromFilePath(photo.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.trim().isEmpty) {
        throw 'Không tìm thấy văn bản nào trong ảnh!';
      }

      // 4. Phân tích qua LLM On-Device
      _updateStatus('Mô hình AI đang xử lý...');
      final T parsedResult = await _parseWithLlama(recognizedText.text);

      // 5. Trả kết quả hoặc Hiển thị Preview Dialog
      if (mounted) {
        if (widget.showPreviewDialog) {
          await _showM3ResultDialog(parsedResult);
        } else {
          widget.onCompleted(parsedResult);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi xử lý: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _stepStatus = '';
        });
      }
    }
  }

  void _updateStatus(String status) {
    if (mounted) setState(() => _stepStatus = status);
  }

  Future<T> _parseWithLlama(String ocrText) async {
    final prompt = widget.promptBuilder(ocrText);
    // Gọi hàm llmProcessor được truyền từ bên ngoài vào
    final rawResponse = await widget.llmProcessor(prompt);
    return widget.parser(rawResponse);
  }

  Future<void> _showM3ResultDialog(T data) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.auto_awesome, color: colorScheme.primary, size: 36),
        title: Text(widget.dialogTitle, textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: widget.previewBuilder != null
              ? widget.previewBuilder!(ctx, data)
              : _buildDefaultPreview(ctx, data),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onCompleted(data);
            },
            icon: const Icon(Icons.check),
            label: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  /// Giao diện xem trước mặc định khi không truyền `previewBuilder`
  Widget _buildDefaultPreview(BuildContext context, T data) {
    final theme = Theme.of(context);
    String displayString = data is Map
        ? const JsonEncoder.withIndent('  ').convert(data)
        : data.toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        displayString,
        style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: _isProcessing ? null : _executePipeline,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Icon(widget.buttonIcon),
          label: Text(
            _isProcessing ? 'Đang xử lý...' : widget.buttonText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isProcessing && _stepStatus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _stepStatus,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
