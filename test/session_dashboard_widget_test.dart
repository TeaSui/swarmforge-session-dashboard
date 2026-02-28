import 'package:flutter_test/flutter_test.dart';
import 'package:repo/main.dart';

void main() {
  testWidgets('renders Session Dashboard shell', (tester) async {
    await tester.pumpWidget(const SessionDashboardApp());
    expect(find.text('SwarmForge Session Dashboard'), findsOneWidget);
    expect(find.text('Active Sessions'), findsOneWidget);
    expect(find.text('Ticket Flow'), findsOneWidget);
  });
}
