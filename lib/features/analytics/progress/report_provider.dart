import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:dio/dio.dart';
// Web-only import for triggering file download
import 'report_web_helper.dart' if (dart.library.io) 'report_stub_helper.dart';

// ─── Report Downloading Service ──────────────────────────────────────────────

final reportDownloadProvider = Provider((ref) => ReportDownloadService(ref));

class ReportDownloadService {
  final Ref _ref;
  ReportDownloadService(this._ref);

  /// Downloads a report via Dio (includes JWT auth header automatically).
  /// On Web: triggers a browser download via JS blob URL.
  /// On Mobile: saves to temp directory.
  Future<void> downloadReport(String path, String fileName) async {
    final dio = _ref.read(dioProvider);

    // Dio always sends the Bearer token (set up in dioProvider interceptors)
    final response = await dio.get(
      path,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = Uint8List.fromList(response.data as List<int>);

    if (kIsWeb) {
      triggerWebDownload(bytes, fileName);
    } else {
      // On Mobile: save to temp directory
      await saveMobileFile(bytes, fileName);
    }
  }

  Future<void> downloadEnterprisePDF(String id) async {
    await downloadReport('/reports/enterprise/$id/pdf', 'Enterprise_Report_$id.pdf');
  }

  Future<void> downloadSystemCSV() async {
    await downloadReport('/reports/system/csv', 'System_Health_Report.csv');
  }
}
