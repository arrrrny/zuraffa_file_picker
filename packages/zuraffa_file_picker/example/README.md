# example

The `zuraffa_file_picker` demonstrator: a Flutter host app that exercises
every `FilePickerPort` operation through the package's public
`FilePickerService` API.

- **Live OS mode** (default) — the GetIt-registered stack, i.e. the real
  method-channel platform adapters on Android, iOS, and macOS. Every
  button opens the actual system picker.
- **Simulator mode** — the same UI over the package's pure-Dart
  `InMemoryFilePickerAdapter`, with producer-side seam buttons to stage
  outcomes (1 file, 3 files, a save path, a directory, or a plain
  cancellation) no real dialog would ever hand you.

Every panel feeds the flow log at the bottom; errors surface verbatim in
a banner (the typed `missing_allowed_extensions` failure comes straight
from the service — a `channel-error` here would prove a missing native
half).

## Plugin operation → where in the app

| Port operation | Panel | What to try |
| --- | --- | --- |
| `pickFiles(FilePickOptions)` | **pickFiles** card | Choose a type (any/media/image/video/audio/custom), extension chips when custom, the Multiple switch, an initial directory, then *Pick files* |
| `saveFile(FileSaveOptions)` | **saveFile** card | Set a file name, toggle *Write sample bytes*, then *Save file* — the returned path is a readable snapshot of the saved document |
| `pickDirectory({initialDirectory})` | **pickDirectory** card | Optionally set an initial directory, then *Pick directory* |
| (cancellation) | any panel | Dismiss the real dialog, or in simulator mode press *Stage cancel (default)* — the outcome is an empty result / `null` path, never an exception |
| (typed failure) | **pickFiles** card | Select type *custom* with no extension chips and run — the `missing_allowed_extensions` banner |

## Run

```sh
cd packages/zuraffa_file_picker/example
flutter pub get
flutter run -d macos   # or an Android emulator / iOS simulator
```

## Tests

```sh
flutter test                                   # full-flow widget tests (simulator)
flutter test integration_test/wiring_test.dart -d macos
```

The widget tests are executable documentation: they drive every port
operation over the simulator, including cancellation and the typed error
path. The integration test runs on a real OS and proves the federated
registration (the platform instance swapped, GetIt resolving the real
method-channel port) without opening any dialog.

## Platform notes

- **Android** — the Storage Access Framework needs no permissions; the
  example's `android/app/build.gradle.kts` raises `minSdk` to 23 (the
  plugin's floor).
- **iOS 14+** — no permission strings needed; the system document picker
  grants access to the files the user selects.
- **macOS 11+** — sandboxed apps work out of the box for user-selected
  files: `macos/Runner/*.entitlements` carries
  `com.apple.security.files.user-selected.read-only` and `.read-write`
  (the latter for save flows).
- On Android, `pickDirectory` resolves only primary-storage trees to a
  filesystem path; other providers fail with `unresolved_directory`.

This example follows the general zuraffa plugin-example contract
(`~/Developer/zuraffa/templates/plugin-example/TEMPLATE.md`): real
driver first, simulator switch, one panel per operation, verbatim error
banner, full-flow widget tests, verification checklist.
