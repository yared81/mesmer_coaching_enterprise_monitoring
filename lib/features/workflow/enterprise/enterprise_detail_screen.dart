import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/session_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/add_session_from_enterprise_sheet.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/user_entity.dart';
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/diagnosis/diagnosis_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/coaching_session_entity.dart';
import 'enterprise_document_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/utils/num_utils.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/api_constants.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/iap/iap_tracker_tab.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coach/coach_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/coaching/phone_followup_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/equipment/equipment_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/equipment/equipment_entity.dart';
import 'graduation_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/qc/qc_audit_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/widgets/sync_indicator.dart';
import 'report_provider.dart';

class EnterpriseDetailScreen extends ConsumerStatefulWidget {
  final String enterpriseId;
  const EnterpriseDetailScreen({super.key, required this.enterpriseId});

  @override
  ConsumerState<EnterpriseDetailScreen> createState() => _EnterpriseDetailScreenState();
}

class _EnterpriseDetailScreenState extends ConsumerState<EnterpriseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Reduced mock tasks for new entities - in a real app these come from a dedicated provider
  final List<_Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Health helpers now derived from real diagnosis data when available
  Color _healthColorForPercentage(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _healthLabelForPercentage(double percentage) {
    if (percentage >= 80) return 'Healthy';
    if (percentage >= 50) return 'Moderate';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final enterpriseAsync = ref.watch(enterpriseDetailProvider(widget.enterpriseId));

    return enterpriseAsync.when(
      data: (enterprise) {
        return _buildBody(context, enterprise);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildBody(BuildContext context, EnterpriseEntity enterprise) {
    // We read performance here so the header can reflect the latest diagnosis health
    final performanceAsync = ref.watch(enterprisePerformanceProvider(enterprise.id));
    final currentUser = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          // ── Hero Header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280, // Increased height to prevent overlap
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF3D5AFE),
            foregroundColor: Colors.white,
            actions: [
              SyncIndicator(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'edit') {
                    if (currentUser?.role == UserRole.enterprise) {
                      final hoursSinceReg = DateTime.now().difference(enterprise.registeredAt).inHours;
                      if (hoursSinceReg > 48) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile locked (48-hour rule). Contact verifier to edit.')),
                        );
                        return;
                      }
                      _showEnterpriseEditSheet(enterprise);
                    }
                  } else if (value == 'reassign') {
                    _showReassignCoachSheet(context, ref, enterprise);
                  } else if (value == 'graduate') {
                    _handleGraduationRequest(context, ref, enterprise);
                  } else if (value == 'export_pdf') {
                    await _exportEnterprisePdf(context, ref, enterprise.id);
                  }
                },
                itemBuilder: (context) {
                  final hoursSinceReg = DateTime.now().difference(enterprise.registeredAt).inHours;
                  final isLocked = hoursSinceReg > 48;
                  
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
                    ),
                    if (currentUser?.role == UserRole.regionalCoordinator)
                      const PopupMenuItem(
                        value: 'reassign',
                        child: Row(children: [Icon(Icons.swap_horiz_rounded, size: 18), SizedBox(width: 8), Text('Reassign')]),
                      ),
                    if (currentUser?.role == UserRole.programManager)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                      ),
                    const PopupMenuItem(
                      value: 'graduate',
                      child: Row(children: [Icon(Icons.school_rounded, size: 18), SizedBox(width: 8), Text('Request Graduation')]),
                    ),
                    const PopupMenuItem(
                      value: 'export_pdf',
                      child: Row(children: [Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 18), SizedBox(width: 8), Text('Export Progress PDF')]),
                    ),
                  ];
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3D5AFE), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 64), // Optimized for different screen heights
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, // Prevents bottom crowding
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    enterprise.businessName,
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${enterprise.sector.name.toUpperCase()} · ${enterprise.location}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        performanceAsync.when(
                          data: (perf) {
                            final current = perf?['current'] as Map<String, dynamic>?;
                            final healthPctRaw = current?['healthPercentage'] ?? current?['health_percentage'];
                            final healthPct = NumUtils.toDouble(healthPctRaw);

                            if (healthPct <= 0) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'No assessment yet',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  _EmployeesChip(enterprise: enterprise),
                                  const _GraduationEligibilityBadge(eligible: false),
                                ],
                              );
                            }

                            final sessionsAsync = ref.watch(enterpriseSessionsProvider(enterprise.id));
                            final isEligible = sessionsAsync.maybeWhen(
                              data: (sessions) => sessions.where((s) => s.status == SessionStatus.completed).length >= 8,
                              orElse: () => false,
                            );

                            final color = _healthColorForPercentage(healthPct);
                            final label = _healthLabelForPercentage(healthPct);
                            return Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _HealthBadge(score: healthPct.toInt(), label: label, color: color),
                                _EmployeesChip(enterprise: enterprise),
                                if (isEligible) const _GraduationEligibilityBadge(eligible: true),
                              ],
                            );
                          },
                          loading: () => Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                width: 80,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              _EmployeesChip(enterprise: enterprise),
                            ],
                          ),
                          error: (_, __) => Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Health unavailable',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              _EmployeesChip(enterprise: enterprise),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Tab bar
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(icon: Icon(Icons.explore_outlined), text: 'OVERVIEW'),
                Tab(icon: Icon(Icons.history_outlined), text: 'SESSIONS'),
                Tab(icon: Icon(Icons.assignment_turned_in_outlined), text: 'ACTION PLAN'),
                Tab(icon: Icon(Icons.folder_open_outlined), text: 'DOCUMENTS'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'EQUIPMENT'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(enterprise, ref),
            _buildTimelineTab(),
            IapTrackerTab(enterpriseId: enterprise.id),
            _buildDocumentsTab(ref),
            _buildEquipmentTab(enterprise.id),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: Overview ──────────────────────────────────────────────────────

  Widget _buildOverviewTab(EnterpriseEntity enterprise, WidgetRef ref) {
    final performanceAsync = ref.watch(enterprisePerformanceProvider(enterprise.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(enterprisePerformanceProvider(enterprise.id));
        ref.invalidate(enterpriseSessionsProvider(enterprise.id));
        await ref.read(enterprisePerformanceProvider(enterprise.id).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator in SingleChildScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Info Card
          _InfoCard(
            title: 'Business Profile',
            icon: Icons.info_outline_rounded,
            children: [
              _InfoRow(Icons.person_rounded, 'Owner', enterprise.ownerName),
              _InfoRow(Icons.phone_rounded, 'Phone', enterprise.phone),
              _InfoRow(Icons.people_rounded, 'Employees', enterprise.employeeCount.toString()),
              _InfoRow(Icons.location_on_rounded, 'Address', enterprise.location),
            ],
          ),
          const SizedBox(height: 20),

          performanceAsync.when(
            data: (perf) {
              final sessionsAsync = ref.watch(enterpriseSessionsProvider(enterprise.id));
              
              if (perf == null) {
                return sessionsAsync.maybeWhen(
                  data: (sessions) {
                    if (sessions.any((s) => s.status == SessionStatus.completed)) {
                      return _buildEmptyPerformanceState(
                        message: 'Assessment results haven\'t been submitted for completed sessions yet.',
                      );
                    }
                    return _buildEmptyPerformanceState();
                  },
                  orElse: () => _buildEmptyPerformanceState(),
                );
              }

              final current = perf['current'] as Map<String, dynamic>?;
              final categoryScores = (current?['categoryScores'] ?? current?['category_scores']) as Map<String, dynamic>?;
              final trendData = (perf['trends'] as List?) ?? [];
              final diagnosisData = categoryScores != null
                  ? {'category_scores': categoryScores}
                  : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Bar Chart (Restored)
                  const _SectionLabel('Assessment Performance'),
                  const SizedBox(height: 12),
                  _buildBarChartCard(diagnosisData?['category_scores'] ?? {}),
                  const SizedBox(height: 20),
                  
                  // 2. Improvement Progress Scorecard
                  if (diagnosisData != null) _buildImprovementScorecard(diagnosisData),
                  const SizedBox(height: 16),
                  
                  // 3. Trend Line Chart
                  _buildTrendChartCard(trendData, current?['healthPercentage'] ?? current?['health_percentage']),
                  const SizedBox(height: 20),

                  // 4. Growth Radar (Comparative View)
                  _buildGrowthRadar(enterprise.id),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(child: Text('Error loading performance: $err')),
          ),
          const SizedBox(height: 48),
        ],
      ),
    ),
  );
}

  Widget _buildEmptyPerformanceState({String? message}) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: _cardDecor(),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No Assessment Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Complete an assessment in the Sessions tab to see performance charts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Strips leading number prefixes like "4. " from category names
  String _cleanCategoryName(String name) {
    return name.replaceFirst(RegExp(r'^\d+\.\s*'), '');
  }

  /// Creates a short abbreviation from a clean category name
  String _abbreviate(String cleanName) {
    final words = cleanName.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      // Take first letter of each word, max 3
      return words.take(3).map((w) => w[0].toUpperCase()).join();
    }
    return cleanName.length > 3 ? cleanName.substring(0, 3).toUpperCase() : cleanName.toUpperCase();
  }

  Widget _buildBarChartCard(Map<String, dynamic> categoryMap) {
    final List<String> catNames = categoryMap.keys.toList();

    // Helper to extract the score regardless of which key is used
    double _catScore(dynamic catData) {
      if (catData == null) return 0.0;
      final m = catData as Map<String, dynamic>;
      // Try 'score' first (from DiagnosisReport.category_scores), then 'average_score'
      final raw = m['score'] ?? m['average_score'] ?? 0;
      return NumUtils.toDouble(raw).clamp(0.0, 5.0);
    }

    if (catNames.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: _cardDecor(),
        child: const Center(
          child: Text('No category data available', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assessment Performance — Score per Category (Max 5.0)',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5,
                minY: 0,
                // Disable value bubbles / tooltips on top of bars for a cleaner view
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60, // Increased for rotated labels
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= catNames.length) return const SizedBox.shrink();
                        final cleanName = _cleanCategoryName(catNames[index]);
                        // Prefer short abbreviation on the axis to avoid overlap; full name is shown below
                        final label = _abbreviate(cleanName);
                        return SideTitleWidget(
                          meta: meta,
                          space: 12,
                          angle: -0.6, // More rotation for clarity
                          child: Text(
                            label.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF616161), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value > 5 || value < 0) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100]!, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(catNames.length, (i) {
                  final catData = categoryMap[catNames[i]];
                  final catMap = catData is Map<String, dynamic> ? catData : <String, dynamic>{};
                  // Use 'score' key (DiagnosisReport format) or fallback to 'average_score'
                  final score = NumUtils.toDouble(catMap['score'] ?? catMap['average_score']).clamp(0.0, 5.0);
                  // Use same color logic as the legend below for visual consistency
                  final Color barColor = score >= 4.0
                      ? const Color(0xFF22C55E)
                      : score >= 2.5
                          ? const Color(0xFF3D5AFE)
                          : const Color(0xFFEF4444);
                  return _makeBarData(i, score, barColor);
                }),
              ),
            ),
          ),
          // ── Legend: full category name + score ──────────────
          const SizedBox(height: 16),
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(catNames.length, (i) {
              final name = catNames[i];
              final cleanName = _cleanCategoryName(name);
              final catData = categoryMap[name];
              final catMap = catData is Map<String, dynamic> ? catData : <String, dynamic>{};
              final score = NumUtils.toDouble(catMap['score'] ?? catMap['average_score']).clamp(0.0, 5.0);
              final pct = score / 5.0;
              final Color barColor = score >= 4.0
                  ? const Color(0xFF22C55E)
                  : score >= 2.5
                      ? const Color(0xFF3D5AFE)
                      : const Color(0xFFEF4444);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cleanName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${score.toStringAsFixed(1)} / 5.0',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: Colors.grey[100],
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementScorecard(Map<String, dynamic> diagnosisData) {
    if (diagnosisData['category_scores'] == null) return const SizedBox.shrink();
    final categories = Map<String, dynamic>.from(diagnosisData['category_scores']);
    
    // Find the weakest categories (< 3.0) to generate impact metrics
    int weakCategoriesCount = 0;
    categories.forEach((name, data) {
      if (NumUtils.toDouble(data['average_score']) < 3.0) {
        weakCategoriesCount++;
      }
    });

    if (weakCategoriesCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Improvement Impact', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$weakCategoriesCount improvement tasks generated based on low scoring diagnostics.',
            style: TextStyle(color: Colors.green[800], fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Mock progress until Tasks tab is built
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.25, // Mock 25% complete
                    backgroundColor: Colors.white,
                    color: Colors.green,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text('25% Complete', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard(List<dynamic> trends, dynamic latestHealthPercentageRaw) {
    if (trends.isEmpty) return const SizedBox.shrink();

    // Parse all dates and compute hour-offset from earliest session
    final parsedDates = trends.map((t) => DateTime.parse(t['date'].toString())).toList();
    final firstDate = parsedDates.reduce((a, b) => a.isBefore(b) ? a : b);

    final List<FlSpot> spots = List.generate(trends.length, (i) {
      // Use hours to avoid everything being collapsed to Day 0 when sessions are close
      final hourOffset = parsedDates[i].difference(firstDate).inHours.toDouble();
      final score = NumUtils.toDouble(trends[i]?['score']);
      return FlSpot(hourOffset, score);
    });

    final maxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    final xRange = maxX > 0 ? maxX : 24.0;

    // Compute improvement delta on 0–5 score scale
    final firstScore = spots.first.y;
    final lastScore = spots.last.y;
    final delta = lastScore - firstScore;
    final improved = delta >= 0;

    // Use latest health percentage, if provided, to color the trend line
    final latestHealthPct = NumUtils.toDouble(latestHealthPercentageRaw);
    final baseColor = latestHealthPct > 0 ? _healthColorForPercentage(latestHealthPct) : (improved ? Colors.green : Colors.red);

    // Deduplicate X-axis date labels
    final Set<String> shownDates = {};

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health Score Trend',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (improved ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${improved ? '▲' : '▼'} ${delta.abs().toStringAsFixed(1)} pts over ${trends.length} sessions',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Each dot = one completed session diagnosis (Max score: 5.0)',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: 5,
                minY: 0,
                minX: 0,
                maxX: xRange,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        // Find the matching trend data
                        final matchIdx = spots.indexWhere((s) => s.x == spot.x && s.y == spot.y);
                        final title = matchIdx >= 0 ? (trends[matchIdx]['sessionTitle'] ?? '') : '';
                        final date = matchIdx >= 0 ? DateFormat('MMM dd').format(parsedDates[matchIdx]) : '';
                        return LineTooltipItem(
                          '$title\n$date: ${spot.y.toStringAsFixed(1)}/5.0',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, m) {
                        // Find nearest spot to this X value with a small margin for double precision
                        final matchIdx = spots.indexWhere((s) => (s.x - v).abs() < 0.5);
                        if (matchIdx < 0) return const SizedBox.shrink();
                        final label = DateFormat('MMM dd').format(parsedDates[matchIdx]);
                        if (shownDates.contains(label)) return const SizedBox.shrink();
                        shownDates.add(label);
                        return SideTitleWidget(
                          meta: m,
                          space: 4,
                          child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 20,
                      getTitlesWidget: (v, m) {
                        if (v < 0 || v > 5) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: m,
                          child: Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(colors: [baseColor.withOpacity(0.5), baseColor]),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [baseColor.withOpacity(0.2), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: Sessions Timeline ──────────────────────────────────────────────

  Widget _buildTimelineTab() {
    final sessionsAsync = ref.watch(enterpriseSessionsProvider(widget.enterpriseId));
    final phoneLogsAsync = ref.watch(enterprisePhoneFollowupsProvider(widget.enterpriseId));
    
    return sessionsAsync.when(
      data: (sessions) => phoneLogsAsync.when(
        data: (phoneLogs) {
          // Combine and sort (sessions use scheduledDate, logs use date)
          final combined = <dynamic>[...sessions, ...phoneLogs]..sort((a, b) {
            final dateA = (a is CoachingSessionEntity) ? a.scheduledDate : (a as PhoneFollowupEntity).date;
            final dateB = (b is CoachingSessionEntity) ? b.scheduledDate : (b as PhoneFollowupEntity).date;
            return dateB.compareTo(dateA);
          });

          return Column(
            children: [
              // ── New Session button bar (always visible at top) ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (_) => AddSessionFromEnterpriseSheet(
                              enterpriseId: widget.enterpriseId,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('New Session', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.phoneLogCreate.replaceAll(':id', widget.enterpriseId));
                        },
                        icon: const Icon(Icons.phone_in_talk_rounded),
                        label: const Text('Log Phone Call', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // ── Combined list ──
              Expanded(
                child: combined.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No sessions yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "New Session" above to record the first coaching session.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: combined.length,
                      itemBuilder: (_, i) {
                        final item = combined[i];
                        if (item is CoachingSessionEntity) {
                          final isCompleted = item.status == SessionStatus.completed;
                          final isPendingSync = item.id.startsWith('offline_');
                          final dotColor = isPendingSync ? Colors.grey : (isCompleted ? const Color(0xFF1E3A8A) : const Color(0xFF16A34A));
                          final accentColor = isPendingSync ? Colors.grey : (isCompleted ? const Color(0xFF3D5AFE) : const Color(0xFF16A34A));
                          
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimelinePin(i == combined.length - 1, dotColor),
                              const SizedBox(width: 16),
                              Expanded(child: _buildSessionCard(item, accentColor)),
                            ],
                          );
                        } else {
                          final log = item as PhoneFollowupEntity;
                          final isPendingSync = log.id.startsWith('offline_');
                          final accentColor = isPendingSync ? Colors.grey : Colors.orange;
                          final dotColor = isPendingSync ? Colors.grey : Colors.orange;
                          
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimelinePin(i == combined.length - 1, dotColor),
                              const SizedBox(width: 16),
                              Expanded(child: _buildPhoneLogCard(log, accentColor)),
                            ],
                          );
                        }
                      },
                    ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildTimelinePin(bool isLast, Color color) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
          ),
        ),
        if (!isLast)
          Container(width: 2, height: 70, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          )),
      ],
    );
  }

  Widget _buildSessionCard(CoachingSessionEntity s, Color accentColor) {
    final isCompleted = s.status == SessionStatus.completed;
    return InkWell(
      onTap: () => context.push('/sessions/detail', extra: s),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 12, color: accentColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(s.title, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(s.scheduledDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            if (s.notes != null && s.notes!.isNotEmpty)
              Text(
                s.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                     s.id.startsWith('offline_') ? 'Pending Sync...' : (isCompleted ? 'Completed' : 'Draft'),
                    style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                if (s.id.startsWith('offline_'))
                  const Icon(Icons.sync_rounded, color: Colors.grey, size: 14)
                else
                  Icon(isCompleted ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                      size: 14, color: accentColor),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.diagnosis, extra: s.id),
                icon: const Icon(Icons.assessment_outlined, size: 16),
                label: const Text('Diagnose', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: BorderSide(color: accentColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLogCard(PhoneFollowupEntity log, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_in_talk_rounded, size: 12, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text('Phone: ${log.purpose}', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 6),
              Text(DateFormat('MMM dd').format(log.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          if (log.issueAddressed?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(log.issueAddressed!, style: const TextStyle(color: Color(0xFF424242), fontSize: 13)),
            ),
          if (log.adviceGiven?.isNotEmpty == true)
            Text('Advice: ${log.adviceGiven}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic)),
          if (log.nextAction?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.next_plan_outlined, size: 12, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Next: ${log.nextAction}', style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.id.startsWith('offline_') ? 'Pending Sync' : 'Logged',
                  style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              if (log.id.startsWith('offline_'))
                const Icon(Icons.sync_rounded, color: Colors.grey, size: 14)
              else
                Icon(Icons.check_circle_rounded, size: 14, color: accentColor),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: Tasks & Recommendations ──────────────────────────────────────

  Widget _buildTasksTab() {
    final completed = _tasks.where((t) => t.done).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecor(),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _tasks.isEmpty ? 0.0 : completed / _tasks.length,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF3D5AFE)),
                      ),
                      Center(
                        child: Text(
                          '${_tasks.isEmpty ? 0 : ((completed / _tasks.length) * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$completed of ${_tasks.length} tasks complete',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${_tasks.length - completed} tasks remaining',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Recommendations'),
          const SizedBox(height: 12),
          if (_tasks.isEmpty)
             Center(
               child: Padding(
                 padding: const EdgeInsets.all(32.0),
                 child: Text('No recommendations generated yet.', style: TextStyle(color: Colors.grey[400])),
               ),
             )
          else
            ...List.generate(_tasks.length, (i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => setState(() => _tasks[i].done = !_tasks[i].done),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _tasks[i].done ? const Color(0xFF3D5AFE) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: _tasks[i].done ? const Color(0xFF3D5AFE) : Colors.grey[300]!, width: 2),
                      ),
                      child: _tasks[i].done
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: Text(
                    _tasks[i].label,
                    style: TextStyle(
                      decoration: _tasks[i].done ? TextDecoration.lineThrough : null,
                      color: _tasks[i].done ? Colors.grey : const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (_tasks[i].done ? Colors.green : Colors.orange).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _tasks[i].done ? 'Done' : 'Pending',
                      style: TextStyle(
                        color: _tasks[i].done ? Colors.green[700] : Colors.orange[700],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ─── TAB 4: Documents & Evidence ──────────────────────────────────────────

  Widget _buildDocumentsTab(WidgetRef ref) {
    final docsAsync = ref.watch(enterpriseDocumentsProvider(widget.enterpriseId));
    
    return docsAsync.when(
      data: (docs) {
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No documents uploaded', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Attach files during a Coaching Session\nto see them grouped here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = docs[i];
            return Container(
              decoration: _cardDecor(),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _EnterpriseDocumentViewerScreen(doc: doc),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF3D5AFE)),
                ),
                title: Text(
                  doc.fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doc.sessionTitle != null) 
                      Text(doc.sessionTitle!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      DateFormat('MMM dd, yyyy').format(doc.uploadedAt),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.grey),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No documents uploaded yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Attach files during a Coaching Session\nto see them grouped here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTab(String enterpriseId) {
    return Consumer(
      builder: (context, ref, _) {
        final assetsAsync = ref.watch(enterpriseEquipmentProvider(enterpriseId));
        return assetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Could not load equipment', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          data: (assets) {
            if (assets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('No equipment recorded', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Program-provided tools or assets will appear here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return _AssetCard(asset: asset);
              },
            );
          },
        );
      },
    );
  }

  void _handleGraduationRequest(BuildContext context, WidgetRef ref, EnterpriseEntity enterprise) async {
    final sessionsAsync = ref.read(enterpriseSessionsProvider(enterprise.id));
    final completedSessions = sessionsAsync.maybeWhen(
      data: (sessions) => sessions.where((s) => s.status == SessionStatus.completed).length,
      orElse: () => 0,
    );

    if (completedSessions < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ineligible: Only $completedSessions/8 sessions completed.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Graduation'),
        content: const Text('This will formally close the coaching cycle for this enterprise and generate a verification code. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Graduate', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(graduationProvider.notifier).request(enterprise.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Graduation successful! Enterprise status updated.')),
          );
          ref.invalidate(enterpriseListProvider); // Refresh to show new status
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Graduation failed: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _exportEnterprisePdf(
    BuildContext context,
    WidgetRef ref,
    String enterpriseId,
  ) async {
    // Show a progress snack bar while generating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Generating PDF report…'),
          ],
        ),
        duration: Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final notifier = ref.read(enterprisePdfDownloadProvider(enterpriseId).notifier);
      await notifier.download();

      final state = ref.read(enterprisePdfDownloadProvider(enterpriseId));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      await state.when(
        data: (bytes) async {
          if (bytes == null) return;
          await Printing.sharePdf(
            bytes: Uint8List.fromList(bytes),
            filename: 'MESMER_Enterprise_Report.pdf',
          );
          notifier.reset();
        },
        loading: () async {},
        error: (e, _) async {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Export failed: $e'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEnterpriseEditSheet(EnterpriseEntity enterprise) {
    final nameController = TextEditingController(text: enterprise.businessName);
    final ownerController = TextEditingController(text: enterprise.ownerName);
    final phoneController = TextEditingController(text: enterprise.phone);
    final locationController = TextEditingController(text: enterprise.location);
    final employeeController = TextEditingController(text: enterprise.employeeCount.toString());
    final yearsController = TextEditingController(text: (enterprise.businessAge ?? 0).toString());
    Sector selectedSector = enterprise.sector;

    final formKey = GlobalKey<FormState>();
    final isEnterpriseOwner = ref.read(authProvider).user?.role == UserRole.enterprise;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Edit Business Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (isEnterpriseOwner) ...[
                  const SizedBox(height: 8),
                  const Text('For compliance, baseline data cannot be altered. Contact your coach to request changes.', 
                    style: TextStyle(color: Colors.orange, fontSize: 13, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  enabled: !isEnterpriseOwner,
                  decoration: const InputDecoration(labelText: 'Business Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ownerController,
                  enabled: !isEnterpriseOwner,
                  decoration: const InputDecoration(labelText: 'Owner Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<Sector>(
                  value: selectedSector,
                  decoration: const InputDecoration(labelText: 'Sector'),
                  items: Sector.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            enabled: !isEnterpriseOwner,
                            child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                          ))
                      .toList(),
                  onChanged: isEnterpriseOwner ? null : (v) => selectedSector = v ?? selectedSector,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: employeeController,
                  enabled: !isEnterpriseOwner,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Employee Count'),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: yearsController,
                  enabled: !isEnterpriseOwner,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Established / Working years'),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: locationController,
                  enabled: !isEnterpriseOwner,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final data = <String, dynamic>{
                        'business_name': nameController.text.trim(),
                        'owner_name': ownerController.text.trim(),
                        'sector': selectedSector.name,
                        'employee_count': int.tryParse(employeeController.text.trim()) ?? enterprise.employeeCount,
                        'business_age': int.tryParse(yearsController.text.trim()) ?? (enterprise.businessAge ?? 0),
                        'phone': phoneController.text.trim(),
                        'location': locationController.text.trim(),
                      };
                      final result = await ref.read(updateEnterpriseUseCaseProvider)(enterprise.id, data);
                      if (!mounted) return;
                      result.fold(
                        (failure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
                          );
                        },
                        (_) {
                          ref.invalidate(enterpriseListProvider);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green),
                          );
                        },
                      );
                    },
                    child: const Text('Save changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      ownerController.dispose();
      phoneController.dispose();
      locationController.dispose();
      employeeController.dispose();
      yearsController.dispose();
    });
  }
  Widget _buildGrowthRadar(String id) {
    final trendsAsync = ref.watch(enterpriseTrendsProvider(id));

    return trendsAsync.when(
      data: (trends) {
        if (trends.isEmpty) return const SizedBox.shrink();

        final revenueSpots = <FlSpot>[];
        final employeeSpots = <FlSpot>[];
        
        for (int i = 0; i < trends.length; i++) {
          final x = i.toDouble();
          revenueSpots.add(FlSpot(x, NumUtils.toDouble(trends[i]['revenue'])));
          employeeSpots.add(FlSpot(x, NumUtils.toDouble(trends[i]['employees'])));
        }

        final maxRevenue = revenueSpots.isNotEmpty 
            ? revenueSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) : 100.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecor(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.radar_rounded, color: Color(0xFF3D5AFE), size: 20),
                  SizedBox(width: 8),
                  Text('Historical Growth Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Longitudinal trajectory of business performance indicators.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxRevenue > 0 ? maxRevenue / 4 : 25,
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100]!, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, m) => Text(
                            v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0),
                            style: TextStyle(color: Colors.grey[400], fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) {
                            final i = v.toInt();
                            if (i < 0 || i >= trends.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                trends[i]['period'],
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: revenueSpots,
                        isCurved: true,
                        color: const Color(0xFF3D5AFE),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: const Color(0xFF3D5AFE).withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildGrowthLegend('Revenue', const Color(0xFF3D5AFE), revenueSpots),
              const SizedBox(height: 12),
              _buildGrowthLegend('Employees', Colors.orange, employeeSpots),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading radar: $err')),
    );
  }

  Widget _buildGrowthLegend(String label, Color color, List<FlSpot> spots) {
    if (spots.length < 2) return const SizedBox.shrink();
    final first = spots.first.y;
    final last = spots.last.y;
    final delta = last - first;
    final pct = first != 0 ? (delta / first * 100) : 0.0;
    
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(
          '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: delta >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Task {
  final String label;
  bool done;
  _Task(this.label, this.done);
}

class _EmployeesChip extends StatelessWidget {
  final EnterpriseEntity enterprise;
  const _EmployeesChip({required this.enterprise});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 13, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            '${enterprise.employeeCount} employees',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

void _showReassignCoachSheet(BuildContext context, WidgetRef ref, EnterpriseEntity enterprise) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final coachesAsync = ref.watch(coachListProvider);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              const Text('Reassign Enterprise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                enterprise.businessName,
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              coachesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Failed to load coaches: $e', style: const TextStyle(color: Colors.red)),
                ),
                data: (coaches) {
                  if (coaches.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No coaches available', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: coaches.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final c = coaches[i];
                        final isCurrent = c.id == enterprise.coachId;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF3D5AFE).withOpacity(0.12),
                            child: Text(
                              (c.name.isNotEmpty ? c.name[0] : 'C').toUpperCase(),
                              style: const TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(c.email, style: const TextStyle(fontSize: 12)),
                          trailing: isCurrent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Current', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                )
                              : const Icon(Icons.chevron_right_rounded),
                          onTap: isCurrent
                              ? null
                              : () async {
                                  final ok = await ref.read(enterpriseListProvider.notifier).assignEnterprise(enterprise.id, c.id);
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok ? 'Reassigned to ${c.name}' : 'Reassign failed'),
                                        backgroundColor: ok ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

BoxDecoration _cardDecor() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
);

class _HealthBadge extends StatelessWidget {
  final int score;
  final String label;
  final Color? color;
  const _HealthBadge({required this.score, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: effectiveColor.withOpacity(0.5)),
      ),
      child: Text(
        '$score% · $label',
        style: TextStyle(
          color: effectiveColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _GraduationEligibilityBadge extends StatelessWidget {
  final bool eligible;
  const _GraduationEligibilityBadge({required this.eligible});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: eligible ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: eligible ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            eligible ? Icons.school_rounded : Icons.lock_outline_rounded, 
            size: 14, 
            color: eligible ? Colors.amber[100] : Colors.white70
          ),
          const SizedBox(width: 6),
          Text(
            eligible ? 'Graduation Eligible' : 'In Progress',
            style: TextStyle(
              color: eligible ? Colors.amber[100] : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)));
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: const Color(0xFF3D5AFE)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A))),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)))),
        ],
      ),
    );
  }
}

BarChartGroupData _makeBarData(int x, double y, Color barColor) {
  return BarChartGroupData(
    x: x,
    // No always-on value labels (scores are shown in the breakdown list below)
    showingTooltipIndicators: const [],
    barRods: [
      BarChartRodData(
        toY: y,
        width: 22,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        gradient: LinearGradient(
          colors: [barColor.withOpacity(0.7), barColor],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    ],
  );
}

class _LegendBadge extends StatelessWidget {
  final String short;
  final String full;
  final double score;
  const _LegendBadge(this.short, this.full, this.score);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFF3D5AFE).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(short, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE))),
          ),
          const SizedBox(width: 6),
          Text(full, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(score.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EnterpriseDocumentViewerScreen extends StatelessWidget {
  final dynamic doc;
  const _EnterpriseDocumentViewerScreen({required this.doc});

  String _resolveUrl(String fileUrl) {
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) return fileUrl;
    // ApiConstants.baseUrl is like http://host:3000/api/v1/; strip the api path.
    final base = ApiConstants.baseUrl.replaceFirst(RegExp(r'/api/v\\d+/?$'), '');
    if (fileUrl.startsWith('/')) return '$base$fileUrl';
    return '$base/$fileUrl';
  }

  bool _isImage(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.png') || u.endsWith('.jpg') || u.endsWith('.jpeg') || u.endsWith('.webp') || u.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl(doc.fileUrl as String);
    final isImage = _isImage(url);

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.fileName as String, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: isImage
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Could not load image preview.', style: TextStyle(color: Colors.white70)),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    },
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview not available for this file type.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    const Text('File URL:', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    SelectableText(url, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    const Text(
                      'Copy the link and open it in a browser.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final EquipmentEntity asset;
  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getStatusColor(asset.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.devices_other, color: _getStatusColor(asset.status), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('S/N: ${asset.serialNumber ?? 'N/A'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                if (asset.notes != null && asset.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(asset.notes!, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(asset.receivedDate),
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(asset.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  asset.status.name.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(asset.status), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.functional: return Colors.green;
      case EquipmentStatus.broken: return Colors.orange;
      case EquipmentStatus.lost: return Colors.red;
      case EquipmentStatus.returned: return Colors.blue;
    }
  }
}
