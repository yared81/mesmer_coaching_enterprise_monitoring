import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/domain/entities/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/providers/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/providers/coaching_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/session_detail_screen.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coaching/presentation/screens/add_session_from_enterprise_sheet.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/presentation/providers/auth_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/domain/entities/user_entity.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../diagnosis/presentation/providers/diagnosis_provider.dart';
import '../../../coaching/domain/entities/coaching_session_entity.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Placeholder business health score (0–100)
  int get _healthScore {
    // Derive from the enterprise id hash for now
    return 45 + (widget.enterpriseId.codeUnits.fold(0, (a, b) => a + b) % 50);
  }

  Color get _healthColor {
    if (_healthScore >= 70) return Colors.green;
    if (_healthScore >= 50) return Colors.orange;
    return Colors.red;
  }

  String get _healthLabel {
    if (_healthScore >= 70) return 'Healthy';
    if (_healthScore >= 50) return 'Moderate';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    return enterprisesAsync.when(
      data: (enterprises) {
        final enterprise = enterprises.firstWhere(
          (e) => e.id == widget.enterpriseId,
          orElse: () => EnterpriseEntity(
            id: '',
            businessName: 'Unknown',
            ownerName: 'Unknown',
            sector: Sector.other,
            employeeCount: 0,
            location: '',
            phone: '',
            coachId: '',
            institutionId: '',
            registeredAt: DateTime.now(),
          ),
        );
        return _buildBody(context, enterprise);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildBody(BuildContext context, EnterpriseEntity enterprise) {
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'edit') {
                    // Logic for edit
                  } else if (value == 'delete') {
                    // Logic for delete
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                  ),
                ],
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _HealthBadge(score: _healthScore, label: _healthLabel),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.people_outline, size: 13, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text('${enterprise.employeeCount} employees',
                                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ]),
                            ),
                          ],
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
                Tab(text: 'Overview'),
                Tab(text: 'Sessions'),
                Tab(text: 'Tasks'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(enterprise, ref),
            _buildTimelineTab(),
            _buildTasksTab(),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: Overview ──────────────────────────────────────────────────────

  Widget _buildOverviewTab(EnterpriseEntity enterprise, WidgetRef ref) {
    final performanceAsync = ref.watch(enterprisePerformanceProvider(enterprise.id));

    return SingleChildScrollView(
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
              if (perf == null) {
                return _buildEmptyPerformanceState();
              }

              final current = perf['current'];
              final trends = (perf['trends'] as List?) ?? [];
              final categoryMap = (current?['categoryScores'] as Map<String, dynamic>?) ?? {};

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bar Chart for Category Scores
                  const _SectionLabel('Assessment Performance'),
                  const SizedBox(height: 12),
                  _buildBarChartCard(categoryMap),
                  const SizedBox(height: 20),

                  // Performance Trend Chart
                  const _SectionLabel('Performance Trend'),
                  const SizedBox(height: 12),
                  _buildTrendChartCard(trends),
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
    );
  }

  Widget _buildEmptyPerformanceState() {
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
            'Complete an assessment in the Sessions tab to see performance charts.',
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

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Core Areas (Out of 5.0)',
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
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final cleanName = _cleanCategoryName(catNames[group.x]);
                      return BarTooltipItem(
                        '$cleanName\n${rod.toY.toStringAsFixed(1)} / 5.0',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= catNames.length) return const SizedBox.shrink();
                        final cleanName = _cleanCategoryName(catNames[index]);
                        final abbr = _abbreviate(cleanName);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            abbr,
                            style: const TextStyle(color: Color(0xFF616161), fontSize: 10, fontWeight: FontWeight.bold),
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
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
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
                  final scoreVal = catData?['average_score'] ?? 0.0;
                  final score = (scoreVal as num).toDouble();
                  return _makeBarData(i, score);
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(catNames.length, (i) {
              final name = catNames[i];
              final cleanName = _cleanCategoryName(name);
              final catData = categoryMap[name];
              final scoreVal = catData?['average_score'] ?? 0.0;
              final score = (scoreVal as num).toDouble();
              final abbr = _abbreviate(cleanName);
              return _LegendBadge(abbr, cleanName, score);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard(List<dynamic> trends) {
    if (trends.isEmpty) return const SizedBox.shrink();

    // Parse all dates and compute day-offset from earliest
    final parsedDates = trends.map((t) => DateTime.parse(t['date'].toString())).toList();
    final firstDate = parsedDates.reduce((a, b) => a.isBefore(b) ? a : b);

    final List<FlSpot> spots = List.generate(trends.length, (i) {
      final dayOffset = parsedDates[i].difference(firstDate).inDays.toDouble();
      final scoreVal = trends[i]?['score'] ?? 0.0;
      final score = (scoreVal as num).toDouble();
      return FlSpot(dayOffset, score);
    });

    // Compute the max X for chart bounds
    final maxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    // Use at least 1 day range to avoid zero-width
    final xRange = maxX > 0 ? maxX : 1.0;

    // Deduplicate X-axis date labels
    final Set<String> shownDates = {};

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Health Progress (Max 5.0)',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
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
                        // Find nearest spot to this X value
                        final matchIdx = spots.indexWhere((s) => s.x == v);
                        if (matchIdx < 0) return const SizedBox.shrink();
                        final label = DateFormat('MMM dd').format(parsedDates[matchIdx]);
                        if (shownDates.contains(label)) return const SizedBox.shrink();
                        shownDates.add(label);
                        return SideTitleWidget(
                          meta: m,
                          child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
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
                        return Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey));
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
                    gradient: LinearGradient(colors: [_healthColor.withOpacity(0.5), _healthColor]),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [_healthColor.withOpacity(0.2), Colors.transparent],
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
    final currentUser = ref.watch(authProvider).user;
    
    return sessionsAsync.when(
      data: (sessions) {
        // Sort newest first
        final sorted = [...sessions]
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

        return Column(
          children: [
            // ── New Session button bar (always visible at top) ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
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
            ),
            const Divider(height: 1),
            // ── Session list ──
            Expanded(
              child: sorted.isEmpty
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
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final s = sorted[i];
                      final isCompleted = s.status == SessionStatus.completed;
                      final dotColor = isCompleted ? const Color(0xFF1E3A8A) : const Color(0xFF16A34A);
                      final accentColor = isCompleted ? const Color(0xFF3D5AFE) : const Color(0xFF16A34A);
                      
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 6)],
                                ),
                              ),
                              if (i < sorted.length - 1)
                                Container(width: 2, height: 70, decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [dotColor, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                )),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                context.push('/sessions/detail', extra: s);
                              },
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
                                            overflow: TextOverflow.ellipsis),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: accentColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isCompleted ? 'Done' : 'Draft',
                                            style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(DateFormat('MMM dd').format(s.scheduledDate), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(s.notes?.isNotEmpty == true ? s.notes! : 'Tap to add session notes or problems identified.', 
                                      style: TextStyle(color: s.notes?.isNotEmpty == true ? const Color(0xFF424242) : Colors.grey[400], fontSize: 13, fontStyle: s.notes?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            context.push(AppRoutes.diagnosis, extra: s.id);
                                          },
                                          icon: const Icon(Icons.assessment_outlined, size: 16),
                                          label: const Text('Diagnose', style: TextStyle(fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accentColor,
                                            side: BorderSide(color: accentColor),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
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
          // Progress summary
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
                        valueColor: AlwaysStoppedAnimation(_healthColor),
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
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Task {
  final String label;
  bool done;
  _Task(this.label, this.done);
}

BoxDecoration _cardDecor() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
);

class _HealthBadge extends StatelessWidget {
  final int score;
  final String label;
  const _HealthBadge({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text('$score% · $label', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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

BarChartGroupData _makeBarData(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        width: 18,
        gradient: const LinearGradient(
          colors: [Color(0xFF3D5AFE), Color(0xFF536DFE)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 5,
          color: Colors.grey[100],
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
