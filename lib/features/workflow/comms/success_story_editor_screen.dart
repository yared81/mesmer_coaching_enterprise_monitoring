import 'package:flutter/material.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';

class SuccessStoryEditorScreen extends StatelessWidget {
  const SuccessStoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Success Stories', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).cardColor,
              child: const TabBar(
                labelColor: Color(0xFFDB2777),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFFDB2777),
                tabs: [
                  Tab(text: 'DRAFTS (3)'),
                  Tab(text: 'PUBLISHED (8)'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDraftsTab(context),
                  _buildPublishedTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFFDB2777),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text('NEW STORY', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDraftsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildStoryCard(
          context,
          title: 'ABC Hardware - From Kiosk to Thriving Store',
          date: 'Created: Mar 23, 2025',
          isDraft: true,
        ),
        _buildStoryCard(
          context,
          title: 'Tesfa Bakery - Baking Success Through Better Records',
          date: 'Created: Mar 22, 2025',
          isDraft: true,
        ),
      ],
    );
  }

  Widget _buildPublishedTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildStoryCard(
          context,
          title: 'Kebede Traders - How Proper Bookkeeping Doubled Sales',
          date: 'Published: Mar 15, 2025',
          isDraft: false,
          views: '245 views',
        ),
      ],
    );
  }

  Widget _buildStoryCard(BuildContext context, {required String title, required String date, bool isDraft = false, String? views}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                if (!isDraft) const Icon(Icons.public, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (views != null) Text(views, style: const TextStyle(fontSize: 12, color: Colors.blue)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share, size: 18), label: const Text('SHARE')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(isDraft ? Icons.edit : Icons.visibility, size: 18),
                  label: Text(isDraft ? 'EDIT' : 'VIEW'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDraft ? const Color(0xFFDB2777) : Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              const Text('Create Success Story', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Enterprise', border: OutlineInputBorder()),
                items: const [DropdownMenuItem(value: '1', child: Text('ABC Hardware'))],
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Story Title', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Summary / Impact Statement', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Key Achievements', style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(value: true, onChanged: (v){}, title: const Text('Increased Revenue')),
              CheckboxListTile(value: true, onChanged: (v){}, title: const Text('New Employment')),
              const SizedBox(height: 16),
              const Text('Media Uploads', style: TextStyle(fontWeight: FontWeight.bold)),
              const Row(
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                  SizedBox(width: 16),
                  Text('Add Before/After Photos'),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE DRAFT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
