import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EnterpriseDetailScreen extends StatefulWidget {
  final String enterpriseId;
  const EnterpriseDetailScreen({super.key, required this.enterpriseId});

  @override
  State<EnterpriseDetailScreen> createState() => _EnterpriseDetailScreenState();
}

class _EnterpriseDetailScreenState extends State<EnterpriseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tasks = [
    _Task('Set up bookkeeping system', false),
    _Task('Create social media accounts', true),
    _Task('Attend financial literacy workshop', true),
    _Task('Develop marketing strategy', false),
    _Task('Register for tax compliance', false),
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          // ── Hero Header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: _healthColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_healthColor, _healthColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 52, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sunrise Bakery',
                                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Food & Beverage · Bahir Dar',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _HealthBadge(score: _healthScore, label: _healthLabel),
                            const SizedBox(width: 12),
                            Text(
                              'Coach: Samuel Bekele',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Timeline'),
                Tab(text: 'Tasks'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTimelineTab(),
            _buildTasksTab(),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: Overview ──────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
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
              _InfoRow(Icons.person_rounded, 'Owner', 'Almaz Tesfaye'),
              _InfoRow(Icons.phone_rounded, 'Phone', '+251 91 234 5678'),
              _InfoRow(Icons.people_rounded, 'Employees', '12'),
              _InfoRow(Icons.location_on_rounded, 'Address', 'Bahir Dar, Amhara'),
            ],
          ),
          const SizedBox(height: 20),
          // Radar Chart for Category Scores
          const _SectionLabel('Assessment Scores'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecor(),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: RadarChart(
                    RadarChartData(
                      radarTouchData: RadarTouchData(enabled: false),
                      getTitle: (index, angle) {
                        const titles = ['Finance', 'Marketing', 'Operations', 'HR', 'Strategy'];
                        return RadarChartTitle(
                          text: titles[index],
                          angle: angle,
                          positionPercentageOffset: 0.1,
                        );
                      },
                      titleTextStyle: const TextStyle(fontSize: 11, color: Color(0xFF424242), fontWeight: FontWeight.w600),
                      titlePositionPercentageOffset: 0.15,
                      tickCount: 4,
                      tickBorderData: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                      gridBorderData: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
                      radarBorderData: const BorderSide(color: Color(0xFFBDBDBD), width: 1.5),
                      dataSets: [
                        RadarDataSet(
                          fillColor: _healthColor.withValues(alpha: 0.2),
                          borderColor: _healthColor,
                          borderWidth: 2.5,
                          entryRadius: 5,
                          dataEntries: [
                            const RadarEntry(value: 3.2),
                            const RadarEntry(value: 2.8),
                            const RadarEntry(value: 3.8),
                            const RadarEntry(value: 2.4),
                            const RadarEntry(value: 3.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _LegendDot('Finance', 32, _healthColor),
                    _LegendDot('Marketing', 28, _healthColor),
                    _LegendDot('Operations', 38, _healthColor),
                    _LegendDot('HR', 24, _healthColor),
                    _LegendDot('Strategy', 30, _healthColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Individual trend chart
          const _SectionLabel('Performance Trend'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            height: 180,
            decoration: _cardDecor(),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, m) {
                        const months = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
                        final i = v.toInt();
                        if (i < 0 || i >= months.length) return const SizedBox.shrink();
                        return SideTitleWidget(meta: m, child: Text(months[i], style: const TextStyle(fontSize: 10, color: Colors.grey)));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 25), FlSpot(1, 30), FlSpot(2, 28), FlSpot(3, 35), FlSpot(4, 40), FlSpot(5, 45)],
                    isCurved: true,
                    gradient: LinearGradient(colors: [_healthColor.withValues(alpha: 0.5), _healthColor]),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [_healthColor.withValues(alpha: 0.2), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ─── TAB 2: Coaching Timeline ──────────────────────────────────────────────

  Widget _buildTimelineTab() {
    final sessions = [
      ('Mar 10, 2026', 'Samuel Bekele', 'Financial planning and bookkeeping session.'),
      ('Feb 28, 2026', 'Samuel Bekele', 'Marketing strategy workshop with practical exercises.'),
      ('Feb 15, 2026', 'Samuel Bekele', 'First assessment review — identified critical areas.'),
      ('Jan 20, 2026', 'Samuel Bekele', 'Initial onboarding and baseline assessment completed.'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      itemBuilder: (_, i) {
        final s = sessions[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFF3D5AFE).withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                ),
                if (i < sessions.length - 1)
                  Container(width: 2, height: 70, decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF3D5AFE), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  )),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF3D5AFE)),
                        const SizedBox(width: 4),
                        Text(s.$1, style: const TextStyle(color: Color(0xFF3D5AFE), fontSize: 11, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(s.$2, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(s.$3, style: const TextStyle(color: Color(0xFF424242), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
                        value: completed / _tasks.length,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(_healthColor),
                      ),
                      Center(
                        child: Text(
                          '${((completed / _tasks.length) * 100).toInt()}%',
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
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
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
                    color: (_tasks[i].done ? Colors.green : Colors.orange).withValues(alpha: 0.1),
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
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))],
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
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
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

class _LegendDot extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _LegendDot(this.label, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text('$label ($score%)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }
}
