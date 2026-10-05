import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclass_act07/main.dart';

Future<void> tapAction(
  WidgetTester tester,
  String action, [
  int times = 1,
]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.widgetWithText(ElevatedButton, action));
    await tester.pump();
  }
}

void expectMeters(WidgetTester tester, int happiness, int hunger) {
  expect(find.text('Happiness: $happiness'), findsOneWidget);
  expect(find.text('Hunger: $hunger'), findsOneWidget);
  final bars = tester
      .widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .toList();
  expect(bars[0].value, happiness / 100);
  expect(bars[1].value, hunger / 100);
}

void expectCareEnabled(WidgetTester tester, bool enabled) {
  for (final action in ['Feed', 'Play']) {
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, action),
    );
    expect(button.onPressed != null, enabled);
  }
  expect(
    tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Reset'))
        .onPressed,
    isNotNull,
  );
}

void main() {
  testWidgets('Digital Pet loads with initial meters and care buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    expect(find.text('Digital Pet'), findsOneWidget);
    expect(find.text('Take care of your pet'), findsOneWidget);
    expectMeters(tester, 50, 50);
    for (final action in ['Feed', 'Play', 'Reset']) {
      expect(find.widgetWithText(ElevatedButton, action), findsOneWidget);
    }
    expectCareEnabled(tester, true);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Feed applies the below-30 penalty and meters stay bounded', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tapAction(tester, 'Feed');
    expectMeters(tester, 60, 40);
    await tapAction(tester, 'Feed');
    expectMeters(tester, 70, 30);
    await tapAction(tester, 'Feed');
    expectMeters(tester, 50, 20);
    await tapAction(tester, 'Feed', 4);
    expectMeters(tester, 0, 0);
    expect(find.text('Game over'), findsNothing);
    await tapAction(tester, 'Reset');
    await tapAction(tester, 'Play');
    expectMeters(tester, 65, 55);
    await tapAction(tester, 'Play', 12);
    expectMeters(tester, 100, 100);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Hunger reaches 100 before overflow reduces happiness', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tester.pump(const Duration(seconds: 29));
    expectMeters(tester, 50, 50);
    await tester.pump(const Duration(seconds: 1));
    expectMeters(tester, 50, 55);
    await tester.pump(const Duration(minutes: 4));
    expectMeters(tester, 50, 95);
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 50, 100);
    expectCareEnabled(tester, true);
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 30, 100);
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 10, 100);
    expect(find.text('Game over'), findsOneWidget);
    expectCareEnabled(tester, false);
    await tapAction(tester, 'Feed');
    await tapAction(tester, 'Play');
    await tester.pump(const Duration(minutes: 4));
    expectMeters(tester, 10, 100);
    await tapAction(tester, 'Reset');
    expectMeters(tester, 50, 50);
    expectCareEnabled(tester, true);
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 50, 55);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Exactly 80 does not win; above 80 wins after three minutes', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tapAction(tester, 'Play', 2);
    expectMeters(tester, 80, 60);
    await tester.pump(const Duration(minutes: 3));
    expectMeters(tester, 80, 90);
    expect(find.text('You win!'), findsNothing);

    await tapAction(tester, 'Reset');
    await tapAction(tester, 'Play', 3);
    await tester.pump(const Duration(minutes: 2));
    // Another action above 80 must not restart the active win timer.
    await tapAction(tester, 'Feed');
    await tester.pump(const Duration(seconds: 59));
    expect(find.text('You win!'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You win!'), findsOneWidget);
    expectMeters(tester, 100, 85);
    expectCareEnabled(tester, false);
    await tapAction(tester, 'Feed');
    await tapAction(tester, 'Play');
    await tester.pump(const Duration(minutes: 4));
    expectMeters(tester, 100, 85);
    await tapAction(tester, 'Reset');
    expectMeters(tester, 50, 50);
    expectCareEnabled(tester, true);
    expect(find.text('Take care of your pet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Dropping to 80 cancels the win and recovery starts fresh', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tapAction(tester, 'Play', 3);
    await tester.pump(const Duration(minutes: 2));
    await tapAction(tester, 'Feed', 6);
    expectMeters(tester, 80, 25);
    await tester.pump(const Duration(minutes: 1));
    expect(find.text('You win!'), findsNothing);
    await tapAction(tester, 'Play');
    await tester.pump(const Duration(seconds: 179));
    expect(find.text('You win!'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You win!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Hunger overflow cancels an active win timer', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tapAction(tester, 'Play', 10);
    expectMeters(tester, 100, 100);
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 80, 100);
    await tester.pump(const Duration(seconds: 150));
    expect(find.text('You win!'), findsNothing);
    expect(find.text('Game over'), findsOneWidget);
    expectMeters(tester, 0, 100);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Reset replaces timers and disposal cancels both timers', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tapAction(tester, 'Play', 3);
    await tester.pump(const Duration(seconds: 20));
    await tapAction(tester, 'Reset', 3);
    await tester.pump(const Duration(seconds: 10));
    expectMeters(tester, 50, 50);
    await tester.pump(const Duration(seconds: 20));
    expectMeters(tester, 50, 55);
    await tester.pump(const Duration(seconds: 130));
    expectMeters(tester, 50, 75);
    expect(find.text('You win!'), findsNothing);
    await tapAction(tester, 'Play', 3);
    // Unmount while both timers are active, then advance beyond both deadlines.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 4));
    expect(tester.takeException(), isNull);
  });
}
