import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindscroll/main.dart';

void main() {
  testWidgets('Dashboard renders per Figma design', (WidgetTester tester) async {
    await tester.pumpWidget(const MindScroll());

    expect(find.text('MindScroll'), findsOneWidget);
    expect(find.text('🔥 5 Day Streak'), findsOneWidget);
    expect(find.text('My Study Folders'), findsOneWidget);
    expect(find.text('Recent Study Sets'), findsOneWidget);
    expect(find.text('+ New Folder'), findsOneWidget);
    expect(find.text('+ Create Study Set'), findsOneWidget);
    expect(find.text('▶ Start'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Import PDF'), findsOneWidget);
  });

  // Regression: dismissing a create sheet used to crash with
  // "'_dependents.isEmpty': is not true" (controller disposed too early).
  testWidgets('Cancelling create sheets does not throw', (WidgetTester tester) async {
    await tester.pumpWidget(const MindScroll());

    await tester.tap(find.text('+ New Folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('New Folder'), findsNothing);

    await tester.tap(find.text('+ Create Study Set'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Create Study Set'), findsNothing);
  });

  testWidgets('Tapping a folder opens its detail screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MindScroll());

    await tester.tap(find.text('📁 COMP4521 Mobile Dev'));
    await tester.pumpAndSettle();

    // Folder detail header + its sets are visible.
    expect(find.text('Folder'), findsOneWidget);
    expect(find.text('Study sets'), findsOneWidget);
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('Lecture 4 - Cross-Platform'), findsOneWidget);

    // Back returns to the dashboard.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('My Study Folders'), findsOneWidget);
  });

  testWidgets('Creating a folder adds it to the grid', (WidgetTester tester) async {
    await tester.pumpWidget(const MindScroll());

    await tester.tap(find.text('+ New Folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'MATH1013 Calculus');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('📁 MATH1013 Calculus'), findsOneWidget);
  });
}
