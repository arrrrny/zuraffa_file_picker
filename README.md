# zuraffa_file_picker — monorepo

Typed file picking (pick files / save file / pick directory) for the
Zuraffa ecosystem, behind a pure-Dart `FilePickerPort` with federated
platform adapters. Built on the
[Zuraffa](https://pub.dev/packages/zuraffa) framework.

## Platform support

| Platform | Status | Implementation |
| -------- | ------ | -------------- |
| Android  | ✅ full | Storage Access Framework — `zuraffa_file_picker_android` |
| iOS      | ✅ full | `UIDocumentPickerViewController` — `zuraffa_file_picker_ios` (iOS 14+) |
| macOS    | ✅ full | `NSOpenPanel` / `NSSavePanel` — `zuraffa_file_picker_macos` (macOS 11+) |
| Anywhere | ✅ dev/tests | In-memory simulator — `InMemoryFilePickerAdapter`, the pure-Dart default until a platform adapter registers |

## Packages

| Package | Description |
| --- | --- |
| [`packages/zuraffa_file_picker`](packages/zuraffa_file_picker/) | App-facing package: `FilePickerPort`, `FilePickerService`, typed picked-file entities + use case |
| [`packages/zuraffa_file_picker_platform_interface`](packages/zuraffa_file_picker_platform_interface/) | MethodChannel protocol + `FilePickerPort` bridge |
| [`packages/zuraffa_file_picker_android`](packages/zuraffa_file_picker_android/) | Android implementation (Storage Access Framework) |
| [`packages/zuraffa_file_picker_ios`](packages/zuraffa_file_picker_ios/) | iOS implementation (UIDocumentPickerViewController) |
| [`packages/zuraffa_file_picker_macos`](packages/zuraffa_file_picker_macos/) | macOS implementation (NSOpenPanel / NSSavePanel) |

## Getting started

```yaml
dependencies:
  zuraffa_file_picker: ^7.3.0
  # Register the federated adapter for each platform you ship (these give
  # the real OS picker; omit them and the in-memory simulator answers).
  zuraffa_file_picker_android: ^7.3.0
  zuraffa_file_picker_ios: ^7.3.0
  zuraffa_file_picker_macos: ^7.3.0
```

```dart
final getIt = GetIt.instance;
registerFilePickerDependencies(getIt);
final picker = getIt<FilePickerService>();

final picked = await picker.pickFiles(FilePickOptions(type: FileType.image));
final saved = await picker.saveFile(const FileSaveOptions(name: 'out.png'));
final directory = await picker.pickDirectory();
```

Without a platform adapter the port defaults to `InMemoryFilePickerAdapter`,
so picker flows test without a platform; dismissal is an empty result / null
path, never an exception.

The app-facing package ships a full-featured demonstrator app —
[`packages/zuraffa_file_picker/example`](packages/zuraffa_file_picker/example/):
every port operation against the real OS pickers or the in-memory
simulator, with a flow log, verbatim error banner, and executable-documentation
widget tests. Run it with `flutter run` from that directory.

## Adoption status

Healthy but unconsumed: no app consumes this package today. zik_zak removed
it from its pubspec on 2026-10-11 — it was declared but never imported, so
the app reads none of its API. The package remains first-class in the fleet:
mono-released at the family version (7.3.0), exercised by CI on every push
(analyze + test per federated member), and publish-verified before any
release.

Re-adoption into zik_zak is justified when an app feature needs typed file
picking behind the Zuraffa port/adapter architecture. That is a small move:
add the package (and the platform adapters you ship) back to the app's
pubspec at the current fleet version, call
`registerFilePickerDependencies(getIt)`, and the in-memory default keeps the
app's own tests platform-free.

Publish from each package directory (`packages/<name>`); the federated
siblings depend on each other via hosted dependencies. Releases ship only
through the fleet mono bump — see [`PUBLISH.md`](PUBLISH.md).

See [`specs/`](specs/) for the spec-driven development records.
