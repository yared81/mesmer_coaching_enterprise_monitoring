import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';

class AuditLogEntry {
  final String id;
  final String? userName;
  final String? userRole;
  final String action;
  final String tableName;
  final DateTime timestamp;

  AuditLogEntry({
    required this.id,
    this.userName,
    this.userRole,
    required this.action,
    required this.tableName,
    required this.timestamp,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'],
      userName: json['User']?['name'],
      userRole: json['User']?['role'],
      action: json['action'],
      tableName: json['table_name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

final auditLogsProvider = FutureProvider<List<AuditLogEntry>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(ApiConstants.audits);
    final List data = response.data['data'];
    return data.map((json) => AuditLogEntry.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load audit logs: $e');
  }
});
