import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/widgets/m3_ai_ocr_scan_button.dart';
import 'package:shipgo/features/explore/presentation/pages/order_info.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  bool _isGenerating = false;

  Future<String> _runInference(String ocrText) async {
    if (_isGenerating) {
      throw Exception('AI đang xử lý yêu cầu trước đó');
    }
    _isGenerating = true;
    try {
      final cleanOcrText = ocrText
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');

      if (cleanOcrText.isEmpty) {
        throw Exception('OCR không nhận diện được nội dung');
      }
      final response = await _dio.get(
        '/ai/extract/order-info',
        queryParameters: {'ocrText': cleanOcrText},
      );

      // Sửa cách lấy dữ liệu từ Map response.data
      final responseBody = response.data;
      if (responseBody == null || responseBody is! Map<String, dynamic>) {
        throw Exception('Response AI API không hợp lệ');
      }

      final dynamic data = responseBody['data'];
      if (data == null) {
        throw Exception('Response AI API không có trường data');
      }

      return data.toString();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null) {
        throw Exception('AI API lỗi $statusCode: ${e.response?.data}');
      }
      throw Exception('Không thể kết nối đến AI API: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi gọi AI API: $e');
    } finally {
      _isGenerating = false;
    }
  }
  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AiOcrScanButton<OrderInfo>(
        buttonText: 'Quét đơn hàng',
        buttonIcon: Icons.qr_code_scanner,
        dialogTitle: 'Chi Tiết Đơn Hàng',
        llmProcessor: (rawOcrText) async {
          return await _runInference(rawOcrText);
        },
        promptBuilder: (ocrText) => ocrText,
        parser: (llmOutput) {
          return OrderInfo.fromLlmOutput(llmOutput);
        },
        previewBuilder: (context, order) {
          return const SizedBox.shrink();
        },
        onCompleted: (OrderInfo order) {
          print(order.toString());
        },
      ),
    );
  }
}
