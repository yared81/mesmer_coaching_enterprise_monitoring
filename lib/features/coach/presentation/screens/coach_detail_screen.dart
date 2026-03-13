import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/domain/entities/coach_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/providers/coach_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/domain/entities/enterprise_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/providers/enterprise_provider.dart';

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
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    return coachesAsync.when(
      data: (coaches) {
        final coach = coaches.firstWhere(
          (c) => c.id == coachId,
          orElse: () => const CoachEntity(id: '', name: 'Unknown', email: '', isActive: false),
        );

        return enterprisesAsync.when(
          data: (allEnterprises) {
            final assignedEnterprises = allEnterprises.where((e) => e.coachId == coachId).toList();
            return _buildBody(context, ref, coach, assignedEnterprises);
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(body: Center(child: Text('Error loading enterprises: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CoachEntity coach, List<EnterpriseEntity> enterprises) {
    final initials = coach.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    // Calculate real metrics
    final activeEnterprises = enterprises.length; // Simplified for now
    
    final metrics = [
      (activeEnterprises.toString(), 'Enterprises\nAssigned', Icons.storefront_rounded, const Color(0xFF3D5AFE)),
      ('0', 'Sessions\nThis Month', Icons.handshake_rounded, const Color(0xFF00B09B)),
      ('N/A', 'Avg. Health\nScore', Icons.trending_up_rounded, const Color(0xFFFF6F00)),
      ('New', 'Last\nActivity', Icons.schedule_rounded, const Color(0xFF9C27B0)),
    ];

    // Sessions are currently not connected to a provider, so we'll show empty for now as requested
    final sessions = []; 

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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
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
                      Text(coach.email, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: coach.isActive
                              ? Colors.green.withOpacity(0.25)
                              : Colors.red.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                _SectionTitle(
                  'Assigned Enterprises', 
                  '${enterprises.length} total',
                  action: TextButton.icon(
                    onPressed: () => _showAssignBottomSheet(context, ref, coachId),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Assign'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3D5AFE),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: enterprises.length,
                  itemBuilder: (ctx, i) {
                    final e = enterprises[i];
                    // Score is mock for now as it's not in the entity yet
                    final mockScore = 65; 
                    final healthColor = mockScore >= 70
                        ? Colors.green
                        : mockScore >= 50
                            ? Colors.orange
                            : Colors.red;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: healthColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(mockScore.toString(), style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 12))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A))),
                                Text(e.sector.name.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: healthColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              mockScore >= 70 ? 'Healthy' : mockScore >= 50 ? 'Moderate' : 'Critical',
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
                                Container(width: 2, height: 56, color: const Color(0xFF3D5AFE).withOpacity(0.15)),
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
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
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

  void _showAssignBottomSheet(BuildContext context, WidgetRef ref, String coachId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final asyncEnterprises = ref.watch(enterpriseListProvider);
            return asyncEnterprises.when(
              data: (all) {
                final unassigned = all.where((e) => e.coachId == null || e.coachId != coachId).toList();
                if (unassigned.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No unassigned enterprises available.')),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Assign Enterprise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: unassigned.length,
                        itemBuilder: (context, index) {
                          final e = unassigned[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3D5AFE).withOpacity(0.1),
                              child: const Icon(Icons.storefront, color: Color(0xFF3D5AFE), size: 18),
                            ),
                            title: Text(e.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(e.sector.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                            trailing: TextButton(
                              onPressed: () async {
                                final success = await ref.read(enterpriseListProvider.notifier).assignEnterprise(e.id, coachId);
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${e.businessName} assigned to coach.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to assign enterprise.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Assign'),
                            ),
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
          },
        );
      },
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
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
  final Widget? action;
  const _SectionTitle(this.title, this.subtitle, {this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(width: 8),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
