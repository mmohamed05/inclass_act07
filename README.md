# Digital Pet – In-Class Activity 07

Georgia State University Mobile Application Development.

Repository: [mmohamed05/inclass_act07](https://github.com/mmohamed05/inclass_act07)

## Current status

- Team 1 Care Systems is complete on `team-1/care-systems`.
- Team 2 UI/personality from PR #2 is integrated for testing on `integration/digital-pet`.
- Session Controls adds Pause/Resume with real timer cancellation and restart.
- Neither original PR has been merged into `main`.
- The final merged APK has not been built yet.

## Team 1 — Care Systems

Owner: **Mohamed Mohamed**

Responsibilities:

- Feed
- Play
- Reset
- Happiness/hunger state rules
- Meter clamping
- Hunger timer
- Win/loss logic
- Timer cleanup
- Widget tests

The implementation is in `lib/main.dart`, with widget tests in
`test/widget_test.dart`. Happiness and hunger both start at 50 and stay within
0–100. The combined screen uses Team 2’s `PetCareView` with Team 1’s real state,
confirmed pet name, action/session revisions, and Pause/Resume controls.

### Feature evidence

| Feature | Implemented behavior | Widget test evidence |
| --- | --- | --- |
| Feed | Hunger −10; resulting hunger below 30 gives happiness −20, otherwise +10; meters clamped. | Immediate updates, hunger at 30 versus below 30, and lower bounds verified. |
| Play | Happiness +15 and hunger +5; meters clamped. | Immediate updates and upper bounds verified. |
| Hunger Timer | Hunger +5 every 30 seconds while the game is active. | No tick at 29 seconds; tick at 30 seconds and subsequent intervals verified. |
| Overflow Behavior | Reaching hunger 100 from 95 does not reduce happiness; a tick when hunger is already 100 reduces happiness by 20. | Both cases verified, including cancellation of an active win timer. |
| Win Logic | Happiness must remain strictly above 80 continuously for 3 minutes; at 80 or below the timer is canceled, and recovery starts a fresh timer. | Exactly 80, full duration, cancellation/restart, and care-button lockout verified. |
| Loss Logic | Game over when hunger is 100 and happiness is at most 10; care actions and timers stop. | Loss at happiness 10 and 0, disabled Feed/Play, and frozen state verified. |
| Reset | Restores both meters to 50, clears outcomes, cancels the win timer, and replaces the hunger timer. | Reset after win/loss and repeated resets without duplicate hunger ticks verified. |
| Lifecycle Cleanup | Timers start outside `build()` and are canceled in `dispose()`; callbacks guard against an unmounted widget. | Unmounting with both timers active and advancing past their deadlines produces no exception or pending-timer failure. |

## Team 2 — UI/personality (teammate-owned)

The integration branch includes the artwork, editable name, mood presentation,
speech, animated meters, reactions, and reduced-motion support from PR #2.
The original PR branch remains unchanged.

## Setup

With Flutter installed, run these commands from the project directory:

```sh
flutter pub get
flutter run
```

## Validation

```sh
flutter analyze
flutter test
```

See [integration verification](docs/INTEGRATION_VERIFICATION.md) for emulator
observations, limits, and merge considerations.

Current integration evidence:

- `flutter analyze`: no issues.
- `flutter test`: 22 tests passed (care, personality, and session controls).

The widget tests cover initial state, care actions, meter boundaries, timer
behavior, outcomes, reset, and disposal. Tests advance simulated time; production
intervals remain 30 seconds for hunger and 3 minutes for the win condition.
The original Team 1 suite remains covered with updated UI assertions. New tests
verify paused controls and meters, interrupted win timing, fresh intervals on
resume, reset clearing pause, and no duplicate hunger timers.

## Remaining integration work

Review the integration changes and emulator evidence before approving merges.
After the agreed merge, rerun checks on the final branch, then build and validate
the final APK before submission. No release APK or submission has been produced.

## Session Controls — second undergraduate advanced feature

Pause disables Feed/Play, cancels hunger and win timers, and clears visual action
feedback. Resume starts a fresh 30-second hunger interval; happiness above 80
starts a fresh continuous 3-minute win interval. Paused time never counts toward
a win. Reset clears pause/outcomes and replaces timers safely while retaining the
confirmed pet name. Session Controls is separate from Team 2's visual-polish
bundle and implements the requested second advanced feature.

## Team 2 pet personality

The undergraduate Visual polish & accessible motion bundle is implemented in
`lib/pet_personality/`. It includes mood tint and labels, derived speech,
animated meters, action bounce/reactions, and reduced-motion support.

Run the fixture preview with `flutter run -t lib/personality_preview.dart`.
Run checks with `flutter analyze` and `flutter test`.

See [the integration guide](docs/PET_PERSONALITY.md) for state inputs, action
notifications, customization, and learning outcomes. Asset provenance is in
[assets/ATTRIBUTION.txt](assets/ATTRIBUTION.txt). Team 1 still owns care rules,
timers, outcomes, and integration into the main screen. Session Controls now
provides the second feature on the temporary integration branch.

[Component test results](docs/PET_PERSONALITY_TEST_RESULTS.md): analysis passed and all 13 tests passed.

`PetCareView` now supplies a reusable screen body with care-action callbacks and
pet-name confirmation. It is adapted to the Team 1 PR #1 state interface. The
care implementation and combined main.dart are outside the original Team 2 PR;
they are connected on this integration branch.
See the integration guide for the exact connection snippet.
