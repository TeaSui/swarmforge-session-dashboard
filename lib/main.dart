import 'package:flutter/material.dart';

import 'src/theme/dashboard_theme.dart';

void main() {
  runApp(const SessionDashboardApp());
}

class SessionDashboardApp extends StatelessWidget {
  const SessionDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwarmForge Session Dashboard',
      theme: DashboardTheme.build(),
      home: const SessionDashboardPage(),
    );
  }
}

class SessionDashboardPage extends StatelessWidget {
  const SessionDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = const [
      ('SCRUM-55', 'Frontend dashboard shell', 'running'),
      ('SCRUM-56', 'Live status and timeline UI', 'running'),
      ('SCRUM-61', 'UAT and production readiness', 'queued'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwarmForge Session Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _KpiCard(title: 'Active Sessions', value: '3'),
                _KpiCard(title: 'Open PRs', value: '0'),
                _KpiCard(title: 'Chain Health', value: 'Healthy'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Ticket Flow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = sessions[index];
                  return ListTile(
                    tileColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    title: Text('${item.$1} - ${item.$2}'),
                    subtitle: Text('status: ${item.$3}'),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        color: const Color(0xFFECFEFF),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
