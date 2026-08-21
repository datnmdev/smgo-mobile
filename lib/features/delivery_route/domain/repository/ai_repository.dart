import 'package:shipgo/core/resources/data_state.dart';

class ExtractOrderInfoParams {
  final String ocrText;

  ExtractOrderInfoParams({required this.ocrText});
}

abstract class AiRepository {
  Future<DataState<String>> extractOrderInfo({
    required ExtractOrderInfoParams params,
  });
}
