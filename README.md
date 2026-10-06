# Digital Pet – In-Class Activity 07

Georgia State University Mobile Application Development.

Repository: [mmohamed05/inclass_act07](https://github.com/mmohamed05/inclass_act07)

## Final integration status

Undergraduate pathway: the final app combines both team workstreams on `main`.
Human teammate `Prophet-20` approved integration commit `da716c6` on GitHub;
[PR #3](https://github.com/mmohamed05/inclass_act07/pull/3) was merged with a normal
merge commit (`c0ed3b9`), preserving the team history.

Advanced features:

1. **Visual Polish & Accessible Motion** — Team 2's personality and visual bundle.
2. **Session Controls** — Pause/Resume with real timer cancellation and restart.

## Collaboration links

- [Team 1 Care Systems — PR #1](https://github.com/mmohamed05/inclass_act07/pull/1)
- [Team 2 Pet Personality — PR #2](https://github.com/mmohamed05/inclass_act07/pull/2)
- [Final integration — PR #3](https://github.com/mmohamed05/inclass_act07/pull/3)
- [Repository issue tracker](https://github.com/mmohamed05/inclass_act07/issues)

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

Team 2 contributor: **Prophet-20**. The final app includes the artwork, editable name, mood presentation,
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

See [final verification](docs/FINAL_VERIFICATION.md) for merged-main and release
verification. [Integration verification](docs/INTEGRATION_VERIFICATION.md) records
the earlier pre-merge checks.

Final automated results from merged `main`:

- `flutter analyze`: no issues.
- `flutter test`: 22 tests passed (care, personality, and session controls).
- Pixel 7 merged-main run: care, name, pause/resume, reduced motion, and real-time
  win/loss verified; no obvious overflow, Dart exceptions, or crashes.
- Release APK: built successfully, installed on Pixel 7, and launch/core controls
  verified. See the final verification report for logs and scope.

The widget tests cover initial state, care actions, meter boundaries, timer
behavior, outcomes, reset, and disposal. Tests advance simulated time; production
intervals remain 30 seconds for hunger and 3 minutes for the win condition.
The original Team 1 suite remains covered with updated UI assertions. New tests
verify paused controls and meters, interrupted win timing, fresh intervals on
resume, reset clearing pause, and no duplicate hunger timers.

## Release build and deliverables

```sh
flutter build apk --release
mkdir -p submission
cp build/app/outputs/flutter-apk/app-release.apk submission/DigitalPet_Team1Team2.apk
```

The original generated APK remains at
`build/app/outputs/flutter-apk/app-release.apk`. The submission copy is
`submission/DigitalPet_Team1Team2.apk`; APKs are separate deliverables and are not
committed. `submission/github_link.txt` contains the repository URL.

Submit the APK, repository link, and your separately prepared personal reflection
through the course's required submission process. The personal reflection is not
generated or overwritten by this project. Nothing has been submitted to iCollege.

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
provides the second feature in the merged main app.

Historical [Team 2 component results](docs/PET_PERSONALITY_TEST_RESULTS.md):
13 tests passed before integration. The final combined suite has 22 tests.

`PetCareView` now supplies a reusable screen body with care-action callbacks and
pet-name confirmation. It is adapted to the Team 1 PR #1 state interface. The
care implementation and combined main.dart are outside the original Team 2 PR;
they are connected in the merged main app.
See the integration guide for the exact connection snippet.
