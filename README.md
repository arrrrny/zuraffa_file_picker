# zuraffa_file_picker — monorepo

Typed file picking (pick files / save file / pick directory) for the
Zuraffa ecosystem, behind a pure-Dart `FilePickerPort` with federated
platform adapters. Built on the
[Zuraffa](https://pub.dev/packages/zuraffa) framework.

## Packages

| Package | Description |
| --- | --- |
| [`packages/zuraffa_file_picker`](packages/zuraffa_file_picker/) | App-facing package: `FilePickerPort`, `FilePickerService`, typed picked-file entities + use case |
| [`packages/zuraffa_file_picker_platform_interface`](packages/zuraffa_file_picker_platform_interface/) | MethodChannel protocol + `FilePickerPort` bridge |
| [`packages/zuraffa_file_picker_android`](packages/zuraffa_file_picker_android/) | Android implementation (Storage Access Framework) |
| [`packages/zuraffa_file_picker_ios`](packages/zuraffa_file_picker_ios/) | iOS implementation (UIDocumentPickerViewController) |
| [`packages/zuraffa_file_picker_macos`](packages/zuraffa_file_picker_macos/) | macOS implementation (NSOpenPanel / NSSavePanel) |

Publish from each package directory (`packages/<name>`); the federated
siblings depend on each other via hosted dependencies.

See [`specs/`](specs/) for the spec-driven development records.
