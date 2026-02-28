import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'src/theme/dashboard_theme.dart';

const String _apiBase = String.fromEnvironment(
  'SWARMFORGE_API_BASE',
  defaultValue: 'http://Infras-ApiSe-26URnOsjHq4N-1518625019.ap-southeast-1.elb.amazonaws.com',
);

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

Uri _endpoint(String path) {
  if (_apiBase.isEmpty) {
    return Uri.parse(path);
  }
  return Uri.parse('$_apiBase$path');
}

class SessionDashboardPage extends StatefulWidget {
  const SessionDashboardPage({super.key});

  @override
  State<SessionDashboardPage> createState() => _SessionDashboardPageState();
}

class _SessionDashboardPageState extends State<SessionDashboardPage> {
  late Future<_DashboardPayload> _payloadFuture;

  @override
  void initState() {
    super.initState();
    _payloadFuture = _fetchPayload();
  }

  Future<_DashboardPayload> _fetchPayload() async {
    final overviewRes = await http.get(_endpoint('/dashboard/overview'));
    final sessionsRes = await http.get(_endpoint('/dashboard/sessions'));
    if (overviewRes.statusCode >= 300 || sessionsRes.statusCode >= 300) {
      throw Exception('Failed to fetch dashboard data');
    }
    final overview = jsonDecode(overviewRes.body) as Map<String, dynamic>;
    final sessionsMap = jsonDecode(sessionsRes.body) as Map<String, dynamic>;
    final sessions = (sessionsMap['items'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return _DashboardPayload(overview: overview, sessions: sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwarmForge Session Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<_DashboardPayload>(
          future: _payloadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load live data: ${snapshot.error}'),
              );
            }
            final payload = snapshot.data!;
            final overview = payload.overview;
            final sessions = payload.sessions;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _KpiCard(title: 'Active Sessions', value: '${overview['active_sessions'] ?? '-'}'),
                    _KpiCard(title: 'Open PRs', value: '${overview['open_prs'] ?? '-'}'),
                    _KpiCard(title: 'Chain Health', value: '${overview['chain_health'] ?? '-'}'),
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
                        title: Text('${item['key']} - ${item['summary']}'),
                        subtitle: Text('status: ${item['status']}'),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardPayload {
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> sessions;

  _DashboardPayload({required this.overview, required this.sessions});
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
