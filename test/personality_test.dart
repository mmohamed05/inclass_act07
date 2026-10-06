import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclass_act07/pet_personality/pet_personality.dart';

PetSnapshot snapshot(
        {int happiness = 50,
        int hunger = 50,
        int? energy,
        PetOutcome outcome = PetOutcome.playing}) =>
    PetSnapshot(
        name: 'Pip',
        happiness: happiness,
        hunger: hunger,
        energy: energy,
        outcome: outcome);

Widget host(
        {int happiness = 50,
        int hunger = 50,
        int? energy,
        PetOutcome outcome = PetOutcome.playing,
        bool reduced = false,
        int revision = 0,
        int session = 0}) =>
    MaterialApp(
      home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Scaffold(
              body: SingleChildScrollView(
                  child: PetPersonalityPanel(
            pet: snapshot(
                happiness: happiness,
                hunger: hunger,
                energy: energy,
                outcome: outcome),
            lastAction: PetAction.feed,
            actionRevision: revision,
            sessionRevision: session,
          )))),
    );

void main() {
  const rules = PersonalityRules();
  test('exact mood boundaries agree with assignment', () {
    expect(rules.moodFor(29), PetMood.unhappy);
    expect(rules.moodFor(30), PetMood.neutral);
    expect(rules.moodFor(70), PetMood.neutral);
    expect(rules.moodFor(71), PetMood.happy);
  });
  test('speech priority and optional energy', () {
    expect(rules.messageFor(snapshot(hunger: 100, outcome: PetOutcome.lost)),
        'I need a rest.');
    expect(rules.messageFor(snapshot(hunger: 100, outcome: PetOutcome.won)),
        'Best day ever!');
    expect(rules.messageFor(snapshot(hunger: 81, happiness: 20, energy: 0)),
        "I'm starving!");
    expect(rules.messageFor(snapshot(hunger: 80, happiness: 30, energy: 0)),
        'Play with me?');
    expect(
        rules.messageFor(snapshot(happiness: 31, energy: 19)), 'So sleepy...');
    expect(rules.messageFor(snapshot(energy: 20)), "Hi, I'm Pip!");
    expect(rules.messageFor(snapshot()), "Hi, I'm Pip!");
  });
  testWidgets('labels, tint, and scale match every mood boundary',
      (tester) async {
    const values = [29, 30, 70, 71];
    const labels = ['Unhappy', 'Neutral', 'Neutral', 'Happy'];
    const colors = [Colors.red, Colors.yellow, Colors.yellow, Colors.green];
    const scales = [0.94, 1.0, 1.0, 1.06];
    for (var i = 0; i < values.length; i++) {
      await tester.pumpWidget(host(happiness: values[i]));
      await tester.pumpAndSettle();
      expect(find.text('Mood: ${labels[i]}'), findsOneWidget);
      expect(
          tester.widget<ColorFiltered>(find.byType(ColorFiltered)).colorFilter,
          ColorFilter.mode(colors[i], BlendMode.modulate));
      expect(
          tester
              .widget<AnimatedScale>(find.byKey(const ValueKey('pet-scale')))
              .scale,
          scales[i]);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('values update immediately while meter moves to target',
      (tester) async {
    await tester.pumpWidget(host(happiness: 20));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(happiness: 90));
    expect(find.text('Happiness: 90 / 100'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    final mid = tester
        .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator))
        .first
        .value!;
    expect(mid, greaterThan(0.2));
    expect(mid, lessThan(0.9));
    await tester.pumpAndSettle();
    expect(
        tester
            .widgetList<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator))
            .first
            .value,
        0.9);
  });
  testWidgets('rapid actions replace pending bounce and reaction resets',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpWidget(host(revision: 1));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(host(revision: 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        tester
            .widget<AnimatedScale>(find.byKey(const ValueKey('pet-scale')))
            .scale,
        1.07);
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        tester
            .widget<AnimatedScale>(find.byKey(const ValueKey('pet-scale')))
            .scale,
        1.0);
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('Snack time!'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Snack time!'), findsNothing);
    await tester.pumpAndSettle();
  });
  testWidgets('reduced motion retains messages and exact meter values',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpWidget(host(happiness: 71, revision: 1, reduced: true));
    final scale =
        tester.widget<AnimatedScale>(find.byKey(const ValueKey('pet-scale')));
    expect(scale.scale, 1.0);
    expect(scale.duration, Duration.zero);
    expect(find.byType(AnimatedSwitcher), findsNothing);
    expect(find.text('Mood: Happy'), findsOneWidget);
    expect(find.text('Snack time!'), findsOneWidget);
    expect(
        tester
            .widgetList<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator))
            .first
            .value,
        0.71);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
  testWidgets('reset and outcomes clear feedback; energy remains optional',
      (tester) async {
    await tester.pumpWidget(host());
    expect(find.textContaining('Energy:'), findsNothing);
    await tester.pumpWidget(host(revision: 1, energy: 5));
    expect(find.text('Energy: 5 / 100'), findsOneWidget);
    await tester.pumpWidget(host(revision: 1, session: 1));
    expect(find.text('Snack time!'), findsNothing);
    await tester.pumpWidget(host(revision: 2, session: 1));
    await tester
        .pumpWidget(host(revision: 2, session: 1, outcome: PetOutcome.won));
    expect(find.text('Snack time!'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Best day ever!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
  testWidgets('small screen with large text fits and exposes semantics',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(
          textScaler: TextScaler.linear(2), disableAnimations: true),
      child: Scaffold(
          body: SingleChildScrollView(
              child: PetPersonalityPanel(pet: snapshot()))),
    )));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Happiness'), findsOneWidget);
    expect(find.bySemanticsLabel('Pip, Neutral pet'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
