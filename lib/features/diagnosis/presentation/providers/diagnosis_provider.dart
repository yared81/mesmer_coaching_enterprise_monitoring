import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
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
final latestDiagnosisTemplateProvider = FutureProvider<DiagnosisTemplateEntity>((ref) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  final result = await repository.getLatestTemplate();
  return result.fold(
    (failure) => throw failure.message,
    (template) => template,
  );
});

/// State Management for the active Diagnosis session
class DiagnosisResponseState {
  final Map<String, String> responses; // questionId -> choiceId

  DiagnosisResponseState({this.responses = const {}});

  DiagnosisResponseState copyWith({Map<String, String>? responses}) {
    return DiagnosisResponseState(
      responses: responses ?? this.responses,
    );
  }

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
    return total == 0 ? 0 : answered / total;
  }
}

class DiagnosisNotifier extends StateNotifier<DiagnosisResponseState> {
  DiagnosisNotifier() : super(DiagnosisResponseState());

  void setResponse(String questionId, String choiceId) {
    final newResponses = Map<String, String>.from(state.responses);
    newResponses[questionId] = choiceId;
    state = state.copyWith(responses: newResponses);
  }

  void reset() {
    state = DiagnosisResponseState();
  }
}

final diagnosisStateProvider = StateNotifierProvider<DiagnosisNotifier, DiagnosisResponseState>((ref) {
  return DiagnosisNotifier();
});
