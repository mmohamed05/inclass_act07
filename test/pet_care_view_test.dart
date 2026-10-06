import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclass_act07/pet_personality/pet_personality.dart';

Future<void> press(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('care buttons delegate once and never mutate the input', (
    tester,
  ) async {
    var feeds = 0, plays = 0, resets = 0;
    const pet = PetSnapshot(name: 'Pip', happiness: 50, hunger: 50);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetCareView(
            pet: pet,
            onFeed: () => feeds++,
            onPlay: () => plays++,
            onReset: () => resets++,
            onNameConfirmed: (_) {},
          ),
        ),
      ),
    );
    await press(tester, 'Feed');
    await press(tester, 'Play');
    await press(tester, 'Reset');
    expect([feeds, plays, resets], [1, 1, 1]);
    expect(pet.hunger, 50);
    expect(find.text('Happiness: 50 / 100'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('both outcomes and pause lock care; reset stays enabled', (
    tester,
  ) async {
    var feeds = 0, plays = 0, resets = 0, toggles = 0;
    for (final outcome in PetOutcome.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCareView(
              pet: PetSnapshot(
                name: 'Pip',
                happiness: 50,
                hunger: 50,
                outcome: outcome,
              ),
              paused: outcome == PetOutcome.playing,
              onFeed: () => feeds++,
              onPlay: () => plays++,
              onReset: () => resets++,
              onNameConfirmed: (_) {},
              onTogglePause: () => toggles++,
            ),
          ),
        ),
      );
      await press(tester, 'Feed');
      await press(tester, 'Play');
      await press(tester, 'Reset');
      await press(tester, outcome == PetOutcome.playing ? 'Resume' : 'Pause');
    }
    expect([feeds, plays, resets, toggles], [0, 0, 3, 1]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'name confirmation trims input, rejects blank, and follows parent',
    (tester) async {
      var name = 'Pip';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => PetCareView(
                pet: PetSnapshot(name: name, happiness: 50, hunger: 50),
                onFeed: () {},
                onPlay: () {},
                onReset: () {},
                onNameConfirmed: (value) => update(() => name = value),
              ),
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '  Luna  ');
      expect(name, 'Pip');
      final confirm = find.widgetWithText(OutlinedButton, 'Confirm name');
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(name, 'Luna');
      expect(find.text("Hi, I'm Luna!"), findsOneWidget);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '   ');
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pump();
      expect(name, 'Luna');
      expect(find.text('Enter a pet name.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('view fits small screens and landscape at large text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(320, 640), const Size(640, 320)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: PetCareView(
                pet: const PetSnapshot(name: 'Pip', happiness: 50, hunger: 50),
                onFeed: () {},
                onPlay: () {},
                onReset: () {},
                onNameConfirmed: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Confirm name'),
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
