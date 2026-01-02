import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PatientReportsPage extends StatelessWidget {
  const PatientReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medical Reports'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: api.getMyMedicalReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load reports',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No reports yet'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final r = reports[index];
              final createdAt = DateTime.tryParse(r['created_at'] ?? '') ??
                  DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(r['diagnosis'] ?? 'Diagnosis'),
                  subtitle: Text(
                    '${r['condition'] ?? ''}\n'
                        '${createdAt.toLocal()}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientReportDetailPage(report: r),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PatientReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const PatientReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final imageUrl = report['description_image_url'] as String?;
    final isImage = report['description_type'] == 'image';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnosis',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(report['diagnosis'] ?? ''),
            const SizedBox(height: 12),
            Text('Prescription',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(report['prescription'] ?? ''),
            const SizedBox(height: 12),
            Text('Notes',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(report['notes'] ?? ''),
            const SizedBox(height: 16),
            if (isImage && imageUrl != null && imageUrl.isNotEmpty) ...[
              const Text(
                'Attached Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ] else if (report['description_text'] != null &&
                (report['description_text'] as String).isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(report['description_text']),
            ],
          ],
        ),
      ),
    );
  }
}
