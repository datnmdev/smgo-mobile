import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shipgo/core/resources/usecase.dart';

class UploadMediaUsecase implements Usecase<void, UploadMediaParams> {
  const UploadMediaUsecase();

  @override
  Future<void> call({required UploadMediaParams params}) async {
    await Dio().put(
      params.url,
      data: params.file,
      options: Options(headers: {'Content-Type': params.contentType}),
    );
  }
}

class UploadMediaParams {
  final String url;
  final String contentType;
  final Uint8List file;

  const UploadMediaParams({
    required this.url,
    required this.contentType,
    required this.file,
  });
}
