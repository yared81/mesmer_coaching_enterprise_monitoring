import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/features/dashboard/dashboard_stats_entity.dart';
import 'package:dio/dio.dart';

// ─── Activity Feed ───────────────────────────────────────────────────────────

final activityFeedProvider = FutureProvider<List<ActivityEntity>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConstants.baseUrl}/dashboard/activity-feed');
  final List data = response.data['data'] as List;
  return data.map((e) => ActivityEntity(
    id: e['id'] ?? '',
    type: e['type'] ?? 'general',
    title: e['title'] ?? '',
    description: e['description'] ?? '',
    timestamp: DateTime.tryParse(e['timestamp'] ?? '') ?? DateTime.now(),
  )).toList();
});

// ─── Coach CRM Portfolio ─────────────────────────────────────────────────────

class CoachPortfolioItem {
  final String id;
  final String businessName;
  final String ownerName;
  final String sector;
  final String location;
  final String status;
  final DateTime? lastActivity;
  final int iapTotal;
  final int iapCompleted;
  final int iapOverdue;
  final int iapPercentage;

  const CoachPortfolioItem({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.sector,
    required this.location,
    required this.status,
    this.lastActivity,
    required this.iapTotal,
    required this.iapCompleted,
    required this.iapOverdue,
    required this.iapPercentage,
  });

  factory CoachPortfolioItem.fromJson(Map<String, dynamic> json) {
    final iap = json['iapProgress'] as Map<String, dynamic>? ?? {};
    return CoachPortfolioItem(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      sector: json['sector'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'active',
      lastActivity: json['lastActivity'] != null
          ? DateTime.tryParse(json['lastActivity'])
          : null,
      iapTotal: iap['total'] ?? 0,
      iapCompleted: iap['completed'] ?? 0,
      iapOverdue: iap['overdue'] ?? 0,
      iapPercentage: iap['percentage'] ?? 0,
    );
  }
}

final coachPortfolioProvider = FutureProvider<List<CoachPortfolioItem>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConstants.baseUrl}/dashboard/coach-portfolio');
  final List data = response.data['data'] as List;
  return data.map((e) => CoachPortfolioItem.fromJson(e)).toList();
});
