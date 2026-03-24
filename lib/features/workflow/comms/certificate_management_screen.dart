import 'package:flutter/material.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_colors.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/constants/app_spacing.dart';

class CertificateManagementScreen extends StatelessWidget {
  const CertificateManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Certificate Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF374151),
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFF374151),
                indicatorColor: Color(0xFF374151),
                tabs: [
                  Tab(text: 'GENERATE'),
                  Tab(text: 'ISSUED'),
                  Tab(text: 'VERIFY'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGenerateTab(context),
                  _buildIssuedTab(context),
                  _buildVerifyTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text('SELECT ENTERPRISE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: AppSpacing.md),
        _buildSelectionCard(name: 'ABC Hardware', date: 'Mar 20, 2025'),
        _buildSelectionCard(name: 'Tesfa Bakery', date: 'Mar 18, 2025'),
        const SizedBox(height: AppSpacing.xl),
        const Text('CERTIFICATE TEMPLATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: AppSpacing.md),
        ListTile(
          title: const Text('Standard Completion'),
          leading: Radio<int>(value: 1, groupValue: 1, onChanged: (v){}),
          trailing: const Icon(Icons.image_outlined),
        ),
        ListTile(
          title: const Text('Bilingual (Amharic/English)'),
          leading: Radio<int>(value: 2, groupValue: 1, onChanged: (v){}),
          trailing: const Icon(Icons.image_outlined),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF374151),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('PREVIEW & GENERATE PDF'),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({required String name, required String date}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!),
      ),
      color: Colors.blue[50],
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Completed: $date'),
        trailing: const Icon(Icons.check_circle, color: Colors.blue),
      ),
    );
  }

  Widget _buildIssuedTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildIssuedItem(name: 'ABC Hardware', code: 'MES-2025-001', date: 'Mar 23, 2025'),
        _buildIssuedItem(name: 'Tesfa Bakery', code: 'MES-2025-002', date: 'Mar 23, 2025'),
      ],
    );
  }

  Widget _buildIssuedItem({required String name, required String code, required String date}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Code: $code | Issued: $date'),
        trailing: IconButton(icon: const Icon(Icons.download), onPressed: () {}),
      ),
    );
  }

  Widget _buildVerifyTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.verified_user, size: 64, color: Colors.green),
          const SizedBox(height: 24),
          const Text('Verify Certificate Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter the code printed on the graduation certificate.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Certificate Code (e.g., MES-2025-001)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code_scanner),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('VERIFY STATUS'),
            ),
          ),
        ],
      ),
    );
  }
}
