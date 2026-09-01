import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/data/data_sources/ai_api_service.dart';
import 'package:smgo/features/delivery_route/domain/repository/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiApiService aiApiService;

  AiRepositoryImpl({required this.aiApiService});

  @override
  Future<DataState<String>> extractOrderInfo({
    required ExtractOrderInfoParams params,
  }) async {
    try {
      final httpResponse = await aiApiService.extractOrderInfo(
        ocrText: params.ocrText,
      );
      return DataSuccess(httpResponse.data.data!);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
