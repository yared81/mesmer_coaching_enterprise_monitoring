import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/errors/failure.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/storage/hive_storage.dart';
import '../../data/datasources/diagnosis_remote_datasource.dart';
import '../../data/repositories/diagnosis_repository_impl.dart';
import '../../domain/entities/diagnosis_template_entity.dart';
import '../../domain/repositories/diagnosis_repository.dart';

/// Repository Providers
final diagnosisRemoteDataSourceProvider = Provider<DiagnosisRemoteDataSource>((ref) {
  return DiagnosisRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return DiagnosisRepositoryImpl(
    remoteDataSource: ref.watch(diagnosisRemoteDataSourceProvider),
  );
});

/// Data Providers
final allTemplatesProvider = FutureProvider<List<DiagnosisTemplateEntity>>((ref) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  final result = await repository.listTemplates();
  return result.fold(
    (Failure failure) => throw failure.message,
    (templates) => templates,
  );
});

final latestDiagnosisTemplateProvider = FutureProvider<DiagnosisTemplateEntity>((ref) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  final result = await repository.getLatestTemplate();
  return result.fold(
    (Failure failure) => throw failure.message,
    (template) => template,
  );
});

final diagnosisTemplateByIdProvider = FutureProvider.family<DiagnosisTemplateEntity, String>((ref, id) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  final result = await repository.getTemplateById(id);
  return result.fold(
    (Failure failure) => throw failure.message,
    (template) => template,
  );
});

final existingDiagnosisReportProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, sessionId) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  final result = await repository.getReportBySessionId(sessionId);
  return result.fold(
    (Failure failure) => throw failure.message,
    (report) => report,
  );
});

final enterprisePerformanceProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, enterpriseId) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  final result = await repository.getEnterprisePerformance(enterpriseId);
  return result.fold(
    (Failure failure) => throw failure.message,
    (data) => data,
  );
});

/// State Management for the active Diagnosis session
class DiagnosisResponseState {
  final Map<String, String> responses; // questionId -> choiceId
  final bool isLoading;
  final bool showErrors;

  DiagnosisResponseState({
    this.responses = const {},
    this.isLoading = false,
    this.showErrors = false,
  });

  DiagnosisResponseState copyWith({
    Map<String, String>? responses,
    bool? isLoading,
    bool? showErrors,
  }) {
    return DiagnosisResponseState(
      responses: responses ?? this.responses,
      isLoading: isLoading ?? this.isLoading,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  bool get hasError => !isLoading && responses.isEmpty;

  bool isComplete(DiagnosisTemplateEntity template) {
    for (final category in template.categories) {
      for (final question in category.questions) {
        if (!responses.containsKey(question.id)) return false;
      }
    }
    return true;
  }

  double getProgress(DiagnosisTemplateEntity template) {
    int total = 0;
    int answered = 0;
    for (final category in template.categories) {
      for (final question in category.questions) {
        total++;
        if (responses.containsKey(question.id)) answered++;
      }
    }
    return total == 0 ? 0.0 : answered / total;
  }
}

class DiagnosisNotifier extends StateNotifier<DiagnosisResponseState> {
  final String sessionId;

  DiagnosisNotifier(this.sessionId) : super(DiagnosisResponseState()) {
    _loadInitialState();
  }

  void _loadInitialState() {
    // 1. Load from Hive first (most recent draft)
    final draft = HiveStorage.getDraft(sessionId);
    if (draft != null) {
      state = state.copyWith(responses: draft);
    }
  }

  /// Merges responses from an existing server report.
  /// This takes precedence over local drafts to ensure completed assessments
  /// aren't overwritten by stale local data.
  void mergeServerResponses(List<dynamic> serverResponses) {
    if (serverResponses.isEmpty) return;

    final Map<String, String> newResponses = Map<String, String>.from(state.responses);
    bool changed = false;

    // Merge server responses into the current state
    for (var resp in serverResponses) {
      final qId = resp['question_id'] as String;
      final cId = resp['choice_id'] as String;
      
      if (newResponses[qId] != cId) {
        newResponses[qId] = cId;
        changed = true;
      }
    }
    
    if (changed) {
      state = state.copyWith(responses: newResponses);
      HiveStorage.saveDraft(sessionId, newResponses);
    }
  }

  void setResponse(String questionId, String choiceId) {
    final newResponses = Map<String, String>.from(state.responses);
    newResponses[questionId] = choiceId;
    state = state.copyWith(responses: newResponses);
    
    // Autosave to Hive
    HiveStorage.saveDraft(sessionId, newResponses);
  }

  void setShowErrors(bool show) {
    state = state.copyWith(showErrors: show);
  }

  void reset() {
    state = DiagnosisResponseState();
    HiveStorage.clearDraft(sessionId);
  }

  Future<Either<Failure, Map<String, dynamic>>> submitDiagnosis(
    DiagnosisRepository repository,
    String templateId,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await repository.submitDiagnosis(
        sessionId,
        templateId,
        state.responses,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false);
          return Left(failure);
        },
        (data) {
          reset();
          return Right(data);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return Left(Failure.fromException(e));
    }
  }
}

final diagnosisStateProvider = StateNotifierProvider.family<DiagnosisNotifier, DiagnosisResponseState, String>((ref, sessionId) {
  return DiagnosisNotifier(sessionId);
});
