import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/enterprise_document_entity.dart';
import '../../domain/repositories/enterprise_document_repository.dart';
import '../../data/datasources/enterprise_document_remote_datasource.dart';
import '../../data/repositories/enterprise_document_repository_impl.dart';

final enterpriseDocumentRemoteDataSourceProvider = Provider<EnterpriseDocumentRemoteDataSource>((ref) {
  return EnterpriseDocumentRemoteDataSource(ref.watch(dioProvider));
});

final enterpriseDocumentRepositoryProvider = Provider<EnterpriseDocumentRepository>((ref) {
  return EnterpriseDocumentRepositoryImpl(
    remoteDataSource: ref.watch(enterpriseDocumentRemoteDataSourceProvider),
  );
});

// Fetch all documents for a specific enterprise (Gallery Tab)
final enterpriseDocumentsProvider = FutureProvider.family<List<EnterpriseDocumentEntity>, String>((ref, enterpriseId) async {
  final repository = ref.watch(enterpriseDocumentRepositoryProvider);
  final result = await repository.getEnterpriseDocuments(enterpriseId);
  return result.fold(
    (failure) => throw failure.message,
    (documents) => documents,
  );
});

// Fetch documents for a specific session (Session Details Attachments)
final sessionDocumentsProvider = FutureProvider.family<List<EnterpriseDocumentEntity>, String>((ref, sessionId) async {
  final repository = ref.watch(enterpriseDocumentRepositoryProvider);
  final result = await repository.getSessionDocuments(sessionId);
  return result.fold(
    (failure) => throw failure.message,
    (documents) => documents,
  );
});
