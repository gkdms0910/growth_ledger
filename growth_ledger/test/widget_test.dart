import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growth_ledger/main.dart';

void main() {
  testWidgets('App starts and shows Dashboard Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GrowthLedgerApp());

    // Verify that the initial screen is the Dashboard.
    // It has an AppBar with the title '대시보드'.
    expect(find.text('대시보드'), findsWidgets); // AppBar title and BottomNavBar label

    // Verify that the Goal List screen is not visible initially.
    expect(find.text('내 목표'), findsNothing);

    // Verify bottom navigation bar items are present.
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('Tapping Goal tab navigates to GoalListScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const GrowthLedgerApp());

    // Tap the '목표' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle(); // pumpAndSettle to wait for animations

    // Verify that the GoalListScreen is now visible.
    expect(find.text('내 목표'), findsOneWidget);

    // Verify that the mock goal is displayed.
    expect(find.text('매일 30분 달리기'), findsOneWidget);
  });
}