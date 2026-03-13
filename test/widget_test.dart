import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repo/main.dart';

void main() {
  testWidgets('SessionDashboardApp renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const SessionDashboardApp());
    expect(find.text('SwarmForge Session Dashboard'), findsOneWidget);
  });
}
