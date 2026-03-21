import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_session_entity.dart';
import 'package:dio/dio.dart';

// Fetch all coaching sessions (scheduled and completed) for the current coach
final coachSessionsProvider = FutureProvider<List<CoachingSessionEntity>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConstants.baseUrl}/sessions/coach/me');
  final List data = response.data['data'] as List;
  
  return data.map((e) => CoachingSessionEntity.fromJson(e as Map<String, dynamic>)).toList();
});
