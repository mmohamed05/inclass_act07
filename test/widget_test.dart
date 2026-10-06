import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclass_act07/main.dart';
import 'package:inclass_act07/pet_personality/pet_personality.dart';

Future<void> tapAction(
  WidgetTester tester,
  String action, [
  int times = 1,
]) async {
  for (var i = 0; i < times; i++) {
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, action));
    await tester.tap(find.widgetWithText(ElevatedButton, action));
    await tester.pump();
  }
}

void expectMeters(WidgetTester tester, int happiness, int hunger) {
  expect(find.text('Happiness: $happiness / 100'), findsOneWidget);
  expect(find.text('Hunger: $hunger / 100'), findsOneWidget);
  // Numeric state updates immediately; Team 2 tests meter interpolation.
  final pet = tester.widget<PetCareView>(find.byType(PetCareView)).pet;
  expect(pet.happiness, happiness);
  expect(pet.hunger, hunger);
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
    expect(find.text("Hi, I'm Pip!"), findsOneWidget);
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
    expect(find.text('Game over. Restart to try again.'), findsNothing);
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
    expect(find.text('Game over. Restart to try again.'), findsOneWidget);
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
    expect(find.text('You won! Restart to play again.'), findsNothing);

    await tapAction(tester, 'Reset');
    await tapAction(tester, 'Play', 3);
    await tester.pump(const Duration(minutes: 2));
    // Another action above 80 must not restart the active win timer.
    await tapAction(tester, 'Feed');
    await tester.pump(const Duration(seconds: 59));
    expect(find.text('You won! Restart to play again.'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You won! Restart to play again.'), findsOneWidget);
    expectMeters(tester, 100, 85);
    expectCareEnabled(tester, false);
    await tapAction(tester, 'Feed');
    await tapAction(tester, 'Play');
    await tester.pump(const Duration(minutes: 4));
    expectMeters(tester, 100, 85);
    await tapAction(tester, 'Reset');
    expectMeters(tester, 50, 50);
    expectCareEnabled(tester, true);
    expect(find.text("Hi, I'm Pip!"), findsOneWidget);
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
    expect(find.text('You won! Restart to play again.'), findsNothing);
    await tapAction(tester, 'Play');
    await tester.pump(const Duration(seconds: 179));
    expect(find.text('You won! Restart to play again.'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You won! Restart to play again.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Hunger overflow cancels an active win timer', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tapAction(tester, 'Play', 10);
    expectMeters(tester, 100, 100);
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 80, 100);
    await tester.pump(const Duration(seconds: 150));
    expect(find.text('You won! Restart to play again.'), findsNothing);
    expect(find.text('Game over. Restart to try again.'), findsOneWidget);
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
    expect(find.text('You won! Restart to play again.'), findsNothing);
    await tapAction(tester, 'Play', 3);
    // Unmount while both timers are active, then advance beyond both deadlines.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 4));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Pause blocks care and timers; resume starts one hunger timer', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tester.pump(const Duration(seconds: 20));
    await tapAction(tester, 'Pause');
    expectCareEnabled(tester, false);
    await tapAction(tester, 'Feed');
    await tapAction(tester, 'Play');
    await tester.pump(const Duration(minutes: 4));
    expectMeters(tester, 50, 50);
    expect(find.text('Paused'), findsOneWidget);
    await tapAction(tester, 'Resume');
    expectCareEnabled(tester, true);
    await tester.pump(const Duration(seconds: 29));
    expectMeters(tester, 50, 50);
    await tester.pump(const Duration(seconds: 1));
    expectMeters(tester, 50, 55);
    for (var i = 0; i < 3; i++) {
      await tapAction(tester, 'Pause');
      await tapAction(tester, 'Resume');
    }
    await tester.pump(const Duration(seconds: 30));
    expectMeters(tester, 50, 60);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Pause interrupts high mood and resume requires a fresh three minutes',
    (tester) async {
      await tester.pumpWidget(const DigitalPetApp());
      await tapAction(tester, 'Play', 3);
      await tester.pump(const Duration(minutes: 2));
      await tapAction(tester, 'Feed', 3);
      expectMeters(tester, 100, 55);
      await tapAction(tester, 'Pause');
      final view = tester.widget<PetCareView>(find.byType(PetCareView));
      final revision = view.actionRevision;
      expect(view.sessionRevision, 1);
      expect(find.text('Snack time!'), findsNothing);
      // Also reject direct callbacks, not just disabled button taps.
      view.onFeed();
      view.onPlay();
      await tester.pump(const Duration(minutes: 4));
      expectMeters(tester, 100, 55);
      expect(
        tester.widget<PetCareView>(find.byType(PetCareView)).actionRevision,
        revision,
      );
      expect(find.text('You won! Restart to play again.'), findsNothing);
      await tapAction(tester, 'Resume');
      await tester.pump(const Duration(seconds: 179));
      expect(find.text('You won! Restart to play again.'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('You won! Restart to play again.'), findsOneWidget);
      expectCareEnabled(tester, false);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Pause'),
            )
            .onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Reset clears pause and pending win with one fresh hunger timer',
    (tester) async {
      await tester.pumpWidget(const DigitalPetApp());
      await tapAction(tester, 'Play', 3);
      await tapAction(tester, 'Pause');
      await tapAction(tester, 'Reset', 3);
      expectMeters(tester, 50, 50);
      expectCareEnabled(tester, true);
      final view = tester.widget<PetCareView>(find.byType(PetCareView));
      expect(view.paused, false);
      expect(view.lastAction, isNull);
      expect(view.sessionRevision, 4);
      await tester.pump(const Duration(seconds: 29));
      expectMeters(tester, 50, 50);
      await tester.pump(const Duration(seconds: 1));
      expectMeters(tester, 50, 55);
      await tester.pump(const Duration(seconds: 150));
      expectMeters(tester, 50, 80);
      expect(find.text('You won! Restart to play again.'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
