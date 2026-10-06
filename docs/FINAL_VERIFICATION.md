# Final main verification and submission preparation

## GitHub review and merge

Human teammate `Prophet-20` submitted an `APPROVED` review on PR #3 at
2026-10-06 03:19:25 UTC for integration commit
`da716c64681cd70808cfaaf65c3fcecab3332668`.

PR #3 was merged with a normal merge commit, preserving the collaboration
history: `c0ed3b9c94f5c0b340bad493f29e21a7217d1180`.
GitHub reported `MERGED` at 2026-10-06 03:20:54 UTC. Local `main` was updated and
was clean before final verification. The application source was not changed
following this merge; subsequent edits are documentation and submission metadata.

## Automated checks from main

- `flutter pub get`: succeeded; reported newer packages outside current constraints.
- `dart format lib test`: 9 files checked, 0 changed.
- `flutter analyze`: no issues.
- `flutter test`: all 22 tests passed.

The suite covers care boundaries, continuous win timing, game-over, reset,
disposal, Team 2 presentation/accessibility, and Pause/Resume timer behavior.

## Final debug run on Pixel 7

Existing device: `emulator-5554`, Pixel 7, Android 17 / API 37.
`flutter run -d emulator-5554` launched the merged app successfully.
Observations were made using actual emulator taps and screenshots:

- Pet image rendered with initial happiness/hunger 50/50.
- Name confirmation changed the heading and speech to Luna.
- Feed produced 60/40; Play then produced 75/45.
- Pause disabled Feed/Play and held 75/45 after attempted taps and 31 seconds.
- Resume restarted gameplay: after 31 seconds the values were 75/50.
- Reset restored 50/50 and retained the confirmed name.
- A real three-minute interval above 80 completed with happiness/hunger 95/95,
  the win message, and disabled Feed/Play/Pause buttons.
- With Android transition/animator scales set to zero, Reset and Feed/Play
  remained usable with readable meters and a stable pet size. Original emulator
  settings were restored afterward.
- Starting from 100/100, five real overflow ticks produced 0/100 and the game-over
  message, with Feed/Play/Pause disabled.
- Neutral/Happy/Unhappy mood labels and face icons accompanied the yellow/green/red tint;
  mood was not communicated by color alone.

No obvious overflow, Dart exceptions, or app crashes were observed. Logs included
Gradle Java native-access warnings, emulator slow/skipped frames, and Android
context/keyboard jank-monitor diagnostics (including an internal Java diagnostic
exception); these did not terminate the app.

Actual screenshots are stored locally in ignored `build/final-verification/`.
They are not synthetic, are not committed, and can be removed by `flutter clean`.

## Release build

`flutter build apk --release` succeeded (Flutter reported 48.1 MB). The original
APK remains at `build/app/outputs/flutter-apk/app-release.apk`, and the copy is
`submission/DigitalPet_Team1Team2.apk`. Both have SHA-256:

```text
169c817baebf41ac7cfaa8a4cfd5f1fc15006d2f4f169c9cba8af73045db7905
```

The existing project release configuration uses the development signing key;
this is a release-mode APK for the course deliverable, not a store publishing setup.

## Release APK device check

Installed the generated APK with `adb install -r` on Pixel 7: `Success`.
Launched `com.example.inclass_act07/.MainActivity`: the pet image and initial
50/50 meters appeared. Actual taps verified Feed -> 60/40, Play -> 75/45,
Pause disabling care buttons, Resume enabling them, and Reset -> 50/50.
The release process remained running and its error-level logcat output was empty.
No obvious overflow or crash was observed. Full real-time win/loss and paused
hunger intervals were checked in the main debug run above, not repeated in release.

## Submission scope

`submission/github_link.txt` contains only the repository URL and a newline.
The APK is a separate deliverable, excluded from Git by `/submission/*.apk`.
The personal reflection remains separately owned and was not generated or
modified. No iCollege submission has been performed.
