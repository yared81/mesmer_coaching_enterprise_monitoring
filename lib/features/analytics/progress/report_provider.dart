import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/providers/core_providers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Report Downloading Service ──────────────────────────────────────────────

final reportDownloadProvider = Provider((ref) => ReportDownloadService(ref));

class ReportDownloadService {
  final Ref _ref;
  ReportDownloadService(this._ref);

  /**
   * Downloads a report as PDF or CSV.
   * On Web: Triggers a browser download.
   * On Mobile: Saves to temp directory and opens/notifies.
   */
  Future<void> downloadReport(String path, String fileName) async {
    final dio = _ref.read(dioProvider);
    final url = '${ApiConstants.baseUrl}$path';

    if (kIsWeb) {
      // For Web, simply use url_launcher with target=_blank
      // Note: This requires the backend to set Content-Disposition: attachment
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      // For Mobile, download via Dio and save to local storage
      try {
        final dir = await getTemporaryDirectory();
        final savePath = '${dir.path}/$fileName';
        
        await dio.download(
          url, 
          savePath,
          options: Options(responseType: ResponseType.bytes),
        );
        
        // TODO: Use open_filex to open the file
        print('Downloaded to $savePath');
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> downloadEnterprisePDF(String id) async {
    await downloadReport('/reports/enterprise/$id/pdf', 'Enterprise_Report_$id.pdf');
  }

  Future<void> downloadSystemCSV() async {
    await downloadReport('/reports/system/csv', 'System_Health_Report.csv');
  }
}
