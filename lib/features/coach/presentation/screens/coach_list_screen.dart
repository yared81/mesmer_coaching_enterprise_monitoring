import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/providers/coach_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/domain/entities/coach_entity.dart';

class CoachListScreen extends ConsumerStatefulWidget {
  const CoachListScreen({super.key});

  @override
  ConsumerState<CoachListScreen> createState() => _CoachListScreenState();
}

class _CoachListScreenState extends ConsumerState<CoachListScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All'; // All, Active, Inactive
  bool _showFilters = false;

  static const List<String> _filterOptions = ['All', 'Active', 'Inactive'];

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF3D5AFE),
            foregroundColor: Colors.white,
            title: const Text('Coaches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                    key: ValueKey(_showFilters),
                  ),
                ),
                onPressed: () => setState(() => _showFilters = !_showFilters),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(_showFilters ? 108 : 56),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search coaches…',
                          hintStyle: TextStyle(color: Colors.white60),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white60, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  // Filter chips
                  if (_showFilters)
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        children: _filterOptions.map((f) {
                          final selected = _activeFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: selected,
                              onSelected: (_) => setState(() => _activeFilter = f),
                              backgroundColor: Colors.white.withOpacity(0.85),
                              selectedColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected ? const Color(0xFF3D5AFE) : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        body: coachesAsync.when(
          data: (all) {
            // Apply filters
            final coaches = all.where((c) {
              final matchesSearch = _searchQuery.isEmpty ||
                  c.name.toLowerCase().contains(_searchQuery) ||
                  c.email.toLowerCase().contains(_searchQuery);
              final matchesFilter = _activeFilter == 'All' ||
                  (_activeFilter == 'Active' && c.isActive) ||
                  (_activeFilter == 'Inactive' && !c.isActive);
              return matchesSearch && matchesFilter;
            }).toList();

            if (coaches.isEmpty) {
              return _EmptyState(
                icon: Icons.group_off_rounded,
                title: 'No Coaches Found',
                subtitle: 'Try adjusting your search or filters.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(coachListProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                itemCount: coaches.length,
                itemBuilder: (context, i) => _CoachCard(
                  coach: coaches[i],
                  index: i,
                  onTap: () => context.push('${AppRoutes.coachDetail}/${coaches[i].id}'),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCoach),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Coach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─── Coach Card ────────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  final CoachEntity coach;
  final int index;
  final VoidCallback onTap;

  const _CoachCard({required this.coach, required this.index, required this.onTap});

  static const _gradients = [
    [Color(0xFF3D5AFE), Color(0xFF7B9EFF)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];
    final initials = coach.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    // Placeholder stats (would come from backend)
    final enterprises = 8 + (index * 3) % 12;
    final sessions = 4 + (index * 5) % 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Gradient Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coach.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: coach.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              coach.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: coach.isActive ? Colors.green[700] : Colors.red[700],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coach.email,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Flexible(child: _StatPill(Icons.storefront_rounded, '$enterprises Enterprises', gradient.first)),
                          Flexible(child: _StatPill(Icons.handshake_rounded, '$sessions Sessions', gradient.last)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
