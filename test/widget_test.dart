import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mydaily_planner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyDailyPlannerApp());

    // Check that app loads
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
