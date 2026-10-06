# Team 2 Pet Personality — undergraduate pathway

This is the personality portion, plus a preview harness. Team 1 remains the owner of the real name, happiness, hunger, optional energy, care actions, timers, and outcomes. There are no care rules or win timers in this component.

## Connect to Team 1 PR 1

`PetCareView` is the recommended screen body for the care implementation in PR #1 (`7c25e45`). It includes the personality panel, Feed/Play/Reset buttons, and a confirmed pet-name field. It calls the care layer through callbacks and never implements meter changes, hunger timing, win/loss rules, or reset rules.

In the partner's State, add `String _petName = 'Pip';`, `PetAction? _personalityLastAction;`, and integer revision fields initialized to zero as shown below. Replace the placeholder body with:

```dart
PetCareView(
  pet: PetSnapshot(
    name: _petName,
    happiness: _happiness,
    hunger: _hunger,
    outcome: _gameOver ? PetOutcome.lost
        : _hasWon ? PetOutcome.won : PetOutcome.playing,
  ),
  onFeed: _feedPet,
  onPlay: _playPet,
  onReset: _resetPet,
  onNameConfirmed: (name) => setState(() => _petName = name),
  lastAction: _personalityLastAction,
  actionRevision: _personalityActionRevision,
  sessionRevision: _personalitySessionRevision,
)
```

Use the accepted-action and reset revision updates below. The view already provides SafeArea, scrolling, a width constraint, and name-controller disposal. The host only owns the confirmed name. Keep the same widget key across ordinary updates. Do not wrap it in another vertical scroll view without a bounded height.

`paused` and `onTogglePause` are optional presentation inputs. If Team 1 implements Session controls, pass both and increment `sessionRevision` whenever pausing to clear visual reactions. The button alone does not implement session control or earn a second advanced feature. Team 1 still owns cancellation/resumption of gameplay timers. Without the callback, no Pause/Resume button is shown.

## Copy into the combined project

1. Copy `lib/pet_personality/` into your partner's `lib/` folder.
2. Copy `assets/pet.png` and `assets/ATTRIBUTION.txt` into their `assets/` folder. `pet.svg` is the editable drawing source; Flutter loads the PNG.
3. Add the asset entry below under their **existing** `flutter:` section in `pubspec.yaml`. Do not replace their pubspec or main.dart.
4. Import the component and pass current state on each build. The folder import works regardless of their package name.

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/pet.png
```

```dart
import 'pet_personality/pet_personality.dart';

// Add these presentation event fields to the partner's screen State:
int _personalityActionRevision = 0;
int _personalitySessionRevision = 0;
PetAction? _personalityLastAction;

// Inside the existing screen's build method, in its widget tree:
PetPersonalityPanel(
  pet: PetSnapshot(
    name: _petName,
    happiness: _happiness,
    hunger: _hunger,
    // Omit energy entirely if your partner is not implementing it.
    // energy: _energy,
    outcome: _gameOver
        ? PetOutcome.lost
        : _hasWon ? PetOutcome.won : PetOutcome.playing,
  ),
  lastAction: _personalityLastAction,
  actionRevision: _personalityActionRevision,
  sessionRevision: _personalitySessionRevision,
),
```

Rename the fields on the right to match your partner's code. Construct the snapshot from their real state each time; do not store a second copy of the meters inside the personality component.

Inside the partner's **existing** `setState` for an accepted Feed action, alongside their meter updates, add:

```dart
_personalityLastAction = PetAction.feed;
_personalityActionRevision++;
```

For Play or Rest, use `PetAction.play` or `PetAction.rest`. Increase the revision even for two consecutive identical actions; the panel uses it to detect a new event. Do not nest another `setState` inside theirs. Rejected or disabled actions should not advance the revision. Team 1 must reevaluate outcomes after every accepted state change and disable care actions when the game ends.

Inside their reset `setState`, add:

```dart
_personalityLastAction = null;
_personalitySessionRevision++;
```

Restart still belongs to Team 1: they must reset meters/outcomes and cancel/restart their timers safely. The session revision only clears visual feedback. Terminal outcomes also clear pending feedback automatically. Keep the panel's widget key stable between normal builds. Put the host screen in a `SafeArea` and `SingleChildScrollView` for short screens and large text, as the preview does.

## Easy changes

- `pet_presentation.dart`: speech text, priority, mood thresholds. The supplied thresholds match the assignment: 29 red/unhappy, 30–70 yellow/neutral, 71 green/happy. Speech asks to play at 30 or below, matching the supplied example; that is independent of the red-tint threshold.
- `PetAppearance`: asset path, colors, scales, and durations. Pass an alternate instance through the panel's `appearance:` parameter.
- `_reactionLabel` in `pet_personality_panel.dart`: short action feedback text.
- The original vector source `assets/pet.svg` can be edited and exported to a transparent PNG; no third-party Flutter package is required.
- No pet tap changes happiness. `PetAction.pet` is only a feedback event if the host chooses to send it.

## Undergraduate feature coverage

This delivers **one** advanced feature bundle: Visual polish & accessible motion. It includes action bounce, living meters, expression/message switching, action reactions, mood tint/size, and pet speech. All read the same incoming snapshot; only temporary animation feedback is stored locally. The device's `MediaQuery.disableAnimations` preference disables movement and uses immediate meter/message updates, while labels remain available.

The combined undergraduate app needs **two** advanced features total. Coordinate a second feature with Team 1, such as Session controls. These visual effects collectively count as one feature, not six. Optional energy display does not implement the Energy system; Team 1 would need energy costs/recovery rules for that feature to count. The supplied preview reset is a fixture tool, not the shared app's Session controls feature.

## Preview and check

Requires Flutter with Dart 3 and Material 3 `surfaceContainerHighest` support (Flutter 3.22 or later); checked here with Flutter 3.47.3 / Dart 3.13.3.

```sh
flutter pub get
flutter analyze
flutter test
```

`lib/personality_preview.dart` is a fixture preview with sliders, a submitted pet-name field, motion settings, outcome choices, and buttons that trigger visual feedback. It deliberately does not simulate game rules. To see it in an existing runnable Flutter project, temporarily use it as a separate entry point or copy the panel into your existing screen. Run the standalone fixture preview with `flutter run -t lib/personality_preview.dart`. The default `lib/main.dart` remains the starter screen until Team 1 integrates the care system.

## Test coverage and remaining integration checks

`test/personality_test.dart` checks mood thresholds 29/30/70/71; speech priority and energy omission; labels/tint/scale consistency; meter interpolation with immediate numeric values; replacement of pending feedback during rapid actions; reset/outcome cleanup; reduced motion; disposal; and small-screen large-text layout with semantics.

After integration, check the real Feed/Play/Reset flow, device reduced motion, and the core timer/outcome scenarios with Team 1. These are tests of the component, not evidence that the combined care app or release APK was tested.

## Learning outcomes

| Implementation | Outcome |
| --- | --- |
| Immutable `PetSnapshot` inputs and short-lived local feedback | Distinguishes widget configuration from mutable State |
| `PersonalityRules` mood and speech methods | Derives consistent presentation from one source of truth |
| Cancelable feedback timers and `mounted` guards | Cleans up asynchronous work with the widget lifecycle |
| Interpolated bars with immediate numeric labels | Rebuilds UI from current state without mutating game values |
| Text, mood icons, semantics, and reduced motion | Communicates information without relying on color or movement |
