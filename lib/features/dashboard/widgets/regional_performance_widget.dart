import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/features/admin/user_management_provider.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';

class RegionalPerformanceWidget extends ConsumerWidget {
  const RegionalPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch only root institutions (Regions)
    final institutionsAsync = ref.watch(institutionsListProvider('root'));

    return institutionsAsync.when(
      data: (institutions) {
        if (institutions.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: institutions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final institution = institutions[index];
                  // Mocking performance for now since backend doesn't provide it yet
                  final mockCompletion = (85 - (index * 7)).clamp(10, 100).toDouble();
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.location_city, color: AppColors.primary),
                    ),
                    title: Text(
                      institution.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(institution.region ?? 'Standard Region', style: const TextStyle(fontSize: 12)),
                              Text('${mockCompletion.toInt()}% Active', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: mockCompletion / 100,
                            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
