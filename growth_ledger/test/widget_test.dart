import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growth_ledger/main.dart';
import 'package:growth_ledger/models/goal.dart';

void main() {
  group('App State and Navigation Tests', () {
    // Test 1: Verify that the LoginScreen is displayed when the user is not logged in.
    testWidgets('App shows LoginScreen when not logged in', (WidgetTester tester) async {
      // Build the app in a logged-out state.
      await tester.pumpWidget(const GrowthLedgerApp(testingIsLoggedIn: false));
      // Wait for the UI to build.
      await tester.pump();

      // Expect to find the login button, which is unique to the LoginScreen.
      expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);
      // Expect not to find the HomeScreen title.
      expect(find.text('한눈에 보기'), findsNothing);
    });

    // Test 2: Verify that the HomeScreen is displayed when the user is logged in.
    testWidgets('App shows HomeScreen when logged in with no goals', (WidgetTester tester) async {
      // Build the app in a logged-in state with an empty list of goals.
      await tester.pumpWidget(const GrowthLedgerApp(
        testingIsLoggedIn: true,
        testingGoals: [],
      ));
      // Wait for all frames to render.
      await tester.pumpAndSettle();

      // Expect to find the HomeScreen title.
      expect(find.text('한눈에 보기'), findsOneWidget);
      // Expect to find the summary card, unique to the HomeScreen.
      expect(find.text('오늘의 한눈에 보기'), findsOneWidget);

      // Verify the "no goals" state in the summary using the new ValueKey.
      final totalGoalsValue = tester.widget<Text>(find.byKey(const ValueKey('전체 목표_value')));
      expect(totalGoalsValue.data, '0');
    });

    // Test 3: Test navigation from HomeScreen to GoalListScreen.
    testWidgets('Navigates to GoalListScreen and finds a goal', (WidgetTester tester) async {
      // Create a mock goal.
      final testGoal = Goal(
        id: '1',
        title: 'Complete Widget Test',
        category: 'Testing',
        createdAt: DateTime.now(),
      );

      // Build the app in a logged-in state with the mock goal.
      await tester.pumpWidget(GrowthLedgerApp(
        testingIsLoggedIn: true,
        testingGoals: [testGoal],
      ));
      await tester.pumpAndSettle();

      // Find and tap the '목표 설정' navigation card.
      final goalSetupCard = find.widgetWithText(Card, '목표 설정');
      expect(goalSetupCard, findsOneWidget);
      await tester.tap(find.descendant(of: goalSetupCard, matching: find.byType(ListTile)));
      
      // Wait for the navigation animation to complete.
      await tester.pumpAndSettle();

      // Verify that the GoalListScreen is now visible by checking its title.
      expect(find.text('목표 설정'), findsOneWidget);
      // Verify that the mock goal is displayed on the screen.
      expect(find.text('Complete Widget Test'), findsOneWidget);
    });

    // Test 4: Test adding a new goal via the AddGoalScreen.
    testWidgets('Adds a new goal and displays it on the HomeScreen', (WidgetTester tester) async {
      // Start the app logged in with no goals.
      await tester.pumpWidget(const GrowthLedgerApp(
        testingIsLoggedIn: true,
        testingGoals: [],
      ));
      await tester.pumpAndSettle();

      // Tap the global 'add goal' button in the AppBar.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // We are now on the AddGoalScreen. Verify its title.
      expect(find.text('새 목표 추가'), findsOneWidget);

      // Enter details for the new goal.
      await tester.enterText(find.byKey(const ValueKey('goal_title_field')), 'New Test Goal');
      
      // Tap the '목표 추가' (Add Goal) button.
      await tester.tap(find.text('목표 추가'));
      await tester.pumpAndSettle();

      // After saving, we should be back on the HomeScreen.
      // Verify the summary card values using the unique ValueKeys.
      final totalGoalsValue = tester.widget<Text>(find.byKey(const ValueKey('전체 목표_value')));
      expect(totalGoalsValue.data, '1');

      final inProgressValue = tester.widget<Text>(find.byKey(const ValueKey('진행중_value')));
      expect(inProgressValue.data, '1');

      final completedValue = tester.widget<Text>(find.byKey(const ValueKey('완료_value')));
      expect(completedValue.data, '0');
    });
  });
}
