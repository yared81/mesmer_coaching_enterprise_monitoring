import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/domain/entities/coach_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/providers/coach_provider.dart';

class CoachDetailScreen extends ConsumerWidget {
  final String coachId;
  const CoachDetailScreen({super.key, required this.coachId});

  static const _gradients = [
    [Color(0xFF3D5AFE), Color(0xFF7B9EFF)],
    [Color(0xFF00B09B), Color(0xFF96C93D)],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachListProvider);

    return coachesAsync.when(
      data: (coaches) {
        final coach = coaches.firstWhere(
          (c) => c.id == coachId,
          orElse: () => const CoachEntity(id: '', name: 'Unknown', email: '', isActive: false),
        );
        return _buildBody(context, coach);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildBody(BuildContext context, CoachEntity coach) {
    final initials = coach.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    // Placeholder metrics (would connect to backend)
    final metrics = [
      ('12', 'Enterprises\nAssigned', Icons.storefront_rounded, const Color(0xFF3D5AFE)),
      ('48', 'Sessions\nThis Month', Icons.handshake_rounded, const Color(0xFF00B09B)),
      ('74%', 'Avg. Health\nScore', Icons.trending_up_rounded, const Color(0xFFFF6F00)),
      ('2d', 'Last\nActivity', Icons.schedule_rounded, const Color(0xFF9C27B0)),
    ];

    final enterprises = [
      ('Sunrise Bakery', 'Food & Bev', 72, true),
      ('Green Fields', 'Agriculture', 45, false),
      ('TechHub PLC', 'Technology', 88, true),
      ('Atlas Trading', 'Trade', 60, true),
    ];

    final sessions = [
      ('Mar 10, 2026', 'Recorded session on financial planning and bookkeeping.'),
      ('Feb 28, 2026', 'Conducted marketing strategy workshop for 3 enterprises.'),
      ('Feb 15, 2026', 'Assessment review session completed for Sunrise Bakery.'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF3D5AFE),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3D5AFE), Color(0xFF1A237E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 36),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        coach.name,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(coach.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: coach.isActive
                              ? Colors.green.withValues(alpha: 0.25)
                              : Colors.red.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          coach.isActive ? '● Active' : '● Inactive',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Metric Cards ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                    children: metrics.map((m) => _MiniMetricCard(
                      value: m.$1,
                      label: m.$2,
                      icon: m.$3,
                      color: m.$4,
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Assigned Enterprises ───────────────────────────────────
                _SectionTitle('Assigned Enterprises', '${enterprises.length} total'),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: enterprises.length,
                  itemBuilder: (ctx, i) {
                    final e = enterprises[i];
                    final healthColor = e.$3 >= 70
                        ? Colors.green
                        : e.$3 >= 50
                            ? Colors.orange
                            : Colors.red;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: healthColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(e.$3.toString(), style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 12))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A))),
                                Text(e.$2, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: healthColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e.$3 >= 70 ? 'Healthy' : e.$3 >= 50 ? 'Moderate' : 'Critical',
                              style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ── Recent Sessions ────────────────────────────────────────
                _SectionTitle('Recent Sessions', '${sessions.length} sessions'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: sessions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12, height: 12,
                                decoration: const BoxDecoration(color: Color(0xFF3D5AFE), shape: BoxShape.circle),
                              ),
                              if (i < sessions.length - 1)
                                Container(width: 2, height: 56, color: const Color(0xFF3D5AFE).withValues(alpha: 0.15)),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.$1, style: const TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(s.$2, style: const TextStyle(color: Color(0xFF424242), fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _MiniMetricCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
