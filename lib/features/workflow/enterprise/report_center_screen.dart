import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';
import 'report_provider.dart';

class ReportCenterScreen extends ConsumerWidget {
  const ReportCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final role = user?.role;

    final bool canAccessMasterCsv = role == UserRole.superAdmin ||
        role == UserRole.programManager ||
        role == UserRole.regionalCoordinator ||
        role == UserRole.meOfficer;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Report Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                ? Theme.of(context).cardColor 
                : AppColors.primary,
              gradient: Theme.of(context).brightness == Brightness.dark 
                ? null 
                : const LinearGradient(
                    colors: [Color(0xFF3D5AFE), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(16),
              border: Theme.of(context).brightness == Brightness.dark 
                ? Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))
                : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.summarize_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professional Reports',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Export enterprise progress, summaries & system data',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Section: Coach Reports ────────────────────────────────────────
          _SectionLabel(
            icon: Icons.person_rounded,
            label: 'My Reports',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),

          _ReportCard(
            id: 'weekly',
            icon: Icons.date_range_rounded,
            iconColor: const Color(0xFF3D5AFE),
            iconBg: const Color(0xFFEEF2FF),
            title: 'Weekly Activity Summary',
            subtitle: 'Sessions conducted, new registrations & IAP completions over the last 7 days.',
            format: 'PDF',
            onDownload: () async {
              final notifier = ref.read(weeklyReportDownloadProvider.notifier);
              await notifier.download();
              final state = ref.read(weeklyReportDownloadProvider);
              if (context.mounted) {
                await _handleDownload(
                  context: context,
                  state: state,
                  filename: 'MESMER_Weekly_Summary.pdf',
                  mimeType: 'application/pdf',
                );
                notifier.reset();
              }
            },
            statusProvider: weeklyReportDownloadProvider,
          ),

          const SizedBox(height: 12),

          // ── Section: Supervisor / Admin Reports ───────────────────────────
          if (canAccessMasterCsv) ...[
            const SizedBox(height: 16),
            _SectionLabel(
              icon: Icons.admin_panel_settings_rounded,
              label: 'System-Wide Reports',
              color: const Color(0xFF059669),
            ),
            const SizedBox(height: 12),

            _ReportCard(
              id: 'master_csv',
              icon: Icons.table_chart_rounded,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
              title: 'Master Enterprise List (CSV)',
              subtitle: 'All enterprises with owner details, activity, sector, IAP progress, and coach assignments.',
              format: 'CSV',
              onDownload: () async {
                final notifier = ref.read(masterCsvDownloadProvider.notifier);
                await notifier.download();
                final state = ref.read(masterCsvDownloadProvider);
                if (context.mounted) {
                  await _handleDownload(
                    context: context,
                    state: state,
                    filename: 'MESMER_Master_List.csv',
                    mimeType: 'text/csv',
                  );
                  notifier.reset();
                }
              },
              statusProvider: masterCsvDownloadProvider,
            ),
          ],

          const SizedBox(height: 48),

          // ── Info Footer ───────────────────────────────────────────────────
          Center(
            child: Text(
              'Reports are generated in real-time from live data.',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'An active internet connection is required.',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload({
    required BuildContext context,
    required AsyncValue<List<int>?> state,
    required String filename,
    required String mimeType,
  }) async {
    state.when(
      data: (bytes) async {
        if (bytes == null) return;
        if (mimeType == 'application/pdf') {
          await Printing.sharePdf(
            bytes: Uint8List.fromList(bytes),
            filename: filename,
          );
        } else {
          // For CSV on web/desktop, trigger a browser-style download via printing share
          await Printing.sharePdf(
            bytes: Uint8List.fromList(bytes),
            filename: filename,
          );
        }
        CustomToaster.show(
          context: context,
          message: '$filename ready!',
        );
      },
      loading: () {},
      error: (e, _) {
        CustomToaster.show(
          context: context,
          message: 'Export failed: $e',
          isError: true,
        );
      },
    );
  }
}

// ─── Supporting Widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.format,
    required this.onDownload,
    required this.statusProvider,
  });

  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String format;
  final VoidCallback onDownload;
  final ProviderListenable<AsyncValue<List<int>?>> statusProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(statusProvider);
    final isLoading = downloadState is AsyncLoading;
    final isSuccess = downloadState is AsyncData && downloadState.value != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withOpacity(0.4)
              : Theme.of(context).dividerColor.withOpacity(0.1),
          width: isSuccess ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FormatBadge(format: format),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onDownload,
                      icon: isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(
                              isSuccess ? Icons.check_circle_rounded : Icons.download_rounded,
                              size: 16,
                            ),
                      label: Text(
                        isLoading
                            ? 'Generating…'
                            : isSuccess
                                ? 'Downloaded!'
                                : 'Export $format',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? AppColors.success : iconColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.format});
  final String format;

  @override
  Widget build(BuildContext context) {
    final isPdf = format == 'PDF';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPdf ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        format,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF059669),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
