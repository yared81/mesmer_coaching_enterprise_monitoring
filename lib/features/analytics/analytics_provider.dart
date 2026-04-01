import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:dio/dio.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class SectorAnalytics {
  final String sector;
  final int count;
  final int avgProgress;

  SectorAnalytics({required this.sector, required this.count, required this.avgProgress});

  factory SectorAnalytics.fromJson(Map<String, dynamic> json) {
    return SectorAnalytics(
      sector: json['sector'] ?? 'Unknown',
      count: json['count'] ?? 0,
      avgProgress: json['avgProgress'] ?? 0,
    );
  }
}

class RegionalAnalytics {
  final String region;
  final int enterpriseCount;
  final double avgBaseline;

  RegionalAnalytics({required this.region, required this.enterpriseCount, required this.avgBaseline});

  factory RegionalAnalytics.fromJson(Map<String, dynamic> json) {
    return RegionalAnalytics(
      region: json['region'] ?? 'Unknown',
      enterpriseCount: json['enterpriseCount'] ?? 0,
      avgBaseline: (json['avgBaseline'] ?? 0).toDouble(),
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final sectorAnalyticsProvider = FutureProvider<List<SectorAnalytics>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConstants.baseUrl}/analytics/sectors');
  final List data = response.data['data'] as List;
  return data.map((e) => SectorAnalytics.fromJson(e)).toList();
});

final regionalAnalyticsProvider = FutureProvider<List<RegionalAnalytics>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConstants.baseUrl}/analytics/regions');
  final List data = response.data['data'] as List;
  return data.map((e) => RegionalAnalytics.fromJson(e)).toList();
});
