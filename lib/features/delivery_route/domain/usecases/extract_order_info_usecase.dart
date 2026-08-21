import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/ai_repository.dart';

class ExtractOrderInfoUsecase
    implements Usecase<DataState<String>, ExtractOrderInfoUsecaseParams> {
  final AiRepository aiRepository;

  ExtractOrderInfoUsecase({required this.aiRepository});

  @override
  Future<DataState<String>> call({
    required ExtractOrderInfoUsecaseParams params,
  }) {
    return aiRepository.extractOrderInfo(
      params: ExtractOrderInfoParams(ocrText: params.ocrText),
    );
  }
}

class ExtractOrderInfoUsecaseParams {
  final String ocrText;

  ExtractOrderInfoUsecaseParams({required this.ocrText});
}
