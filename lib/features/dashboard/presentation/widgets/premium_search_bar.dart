import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/presentation/providers/coach_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/presentation/providers/enterprise_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/coach/domain/entities/coach_entity.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/enterprise/domain/entities/enterprise_entity.dart';

class PremiumSearchBar extends ConsumerStatefulWidget {
  const PremiumSearchBar({super.key});

  @override
  ConsumerState<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends ConsumerState<PremiumSearchBar> {
  final SearchController _controller = SearchController();

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachListProvider);
    final enterprisesAsync = ref.watch(enterpriseListProvider);

    return SearchAnchor(
      searchController: _controller,
      viewHintText: 'Search coaches, enterprises...',
      viewLeading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _controller.closeView(null),
      ),
      builder: (context, controller) {
        return IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => controller.openView(),
        );
      },
      suggestionsBuilder: (context, controller) {
        final query = controller.text.toLowerCase();
        
        List<Widget> suggestions = [];

        // Coaches Section
        coachesAsync.whenData((coaches) {
          final filteredCoaches = coaches
              .where((c) => c.name.toLowerCase().contains(query) || c.email.toLowerCase().contains(query))
              .take(3)
              .toList();

          if (filteredCoaches.isNotEmpty) {
            suggestions.add(_buildHeader('Coaches'));
            suggestions.addAll(filteredCoaches.map((coach) => _buildCoachTile(coach)));
          }
        });

        // Enterprises Section
        enterprisesAsync.whenData((enterprises) {
          final filteredEnterprises = enterprises
              .where((e) => e.businessName.toLowerCase().contains(query))
              .take(3)
              .toList();

          if (filteredEnterprises.isNotEmpty) {
            suggestions.add(_buildHeader('Enterprises'));
            suggestions.addAll(filteredEnterprises.map((enterprise) => _buildEnterpriseTile(enterprise)));
          }
        });

        if (suggestions.isEmpty && query.isNotEmpty) {
          return [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No results found')),
            )
          ];
        }

        return suggestions;
      },
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCoachTile(CoachEntity coach) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[50],
        child: Text(coach.name[0], style: const TextStyle(color: Colors.blue)),
      ),
      title: Text(coach.name),
      subtitle: Text(coach.email),
      onTap: () {
        _controller.closeView(coach.name);
        // TODO: Navigate to coach details
      },
    );
  }

  Widget _buildEnterpriseTile(EnterpriseEntity enterprise) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.storefront_rounded, color: Colors.amber[800], size: 20),
      ),
      title: Text(enterprise.businessName),
      subtitle: Text(enterprise.sector.name),
      onTap: () {
        _controller.closeView(enterprise.businessName);
        // TODO: Navigate to enterprise details
      },
    );
  }
}
