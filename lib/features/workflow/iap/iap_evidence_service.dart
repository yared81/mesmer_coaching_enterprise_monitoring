import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';

class IapEvidenceService {
  final Dio _client;
  IapEvidenceService(this._client);

  /// Upload a file as evidence for a given IAP task.
  /// Returns the public URL of the uploaded file.
  Future<String> uploadEvidence({
    required String taskId,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = File(filePath);
    final filename = file.path.split('/').last;

    final formData = FormData.fromMap({
      'evidence': await MultipartFile.fromFile(filePath, filename: filename),
    });

    final response = await _client.post(
      '${ApiConstants.baseUrl}/iaps/tasks/$taskId/evidence',
      data: formData,
      onSendProgress: onProgress,
    );

    return response.data['data']['evidence_url'] as String;
  }

  /// Update task status (pending / completed) via standard PUT.
  Future<void> updateTaskStatus(String taskId, String status) async {
    await _client.put(
      '${ApiConstants.baseUrl}/iaps/tasks/$taskId',
      data: {'status': status},
    );
  }
}

final iapEvidenceServiceProvider = Provider<IapEvidenceService>((ref) {
  return IapEvidenceService(ref.watch(dioProvider));
});
