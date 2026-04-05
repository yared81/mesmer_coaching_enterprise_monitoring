import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_digital_coaching/core/router/app_routes.dart';
import 'package:mesmer_digital_coaching/features/admin/user_management_provider.dart';
import 'package:mesmer_digital_coaching/features/auth/auth_provider.dart';
import 'package:mesmer_digital_coaching/features/auth/user_entity.dart';

class RegionalCoachListScreen extends ConsumerStatefulWidget {
  const RegionalCoachListScreen({super.key});

  @override
  ConsumerState<RegionalCoachListScreen> createState() => _RegionalCoachListScreenState();
}

class _RegionalCoachListScreenState extends ConsumerState<RegionalCoachListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(usersListProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coaches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (user?.institutionName != null)
              Text(user!.institutionName!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(usersListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF3D5AFE),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: coachesAsync.when(
              data: (users) {
                final coaches = users.where((u) {
                  final isCoach = u.role == UserRole.coach;
                  final matchesSearch = u.name.toLowerCase().contains(_searchQuery) || 
                                       u.email.toLowerCase().contains(_searchQuery);
                  return isCoach && matchesSearch;
                }).toList();

                if (coaches.isEmpty) {
                  return const Center(child: Text('No coaches found in your region.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coaches.length,
                  itemBuilder: (context, index) {
                    final coach = coaches[index];
                    return _CoachSupervisionCard(coach: coach);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachSupervisionCard extends StatelessWidget {
  final dynamic coach;
  const _CoachSupervisionCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/coaches/${coach.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF3D5AFE).withOpacity(0.1),
                child: Text(
                  coach.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(coach.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatBadge(
                          icon: Icons.business_center_rounded,
                          label: '${coach.enterpriseCount ?? 0} Enterprises',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _StatBadge(
                          icon: Icons.history_edu_rounded,
                          label: '${coach.sessionCount ?? 0} Sessions',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
