## 7.3.2 - 2026-10-31

Mono-version fleet alignment to 7.3.2: outbound send port lands in zuraffa_intents (shareText/shareFiles behind ShareIntentService); the whole family ships at one version.

## Unreleased

- The wire gains the `source` request key (spec 002): the resolved picker
  source (`document` / `photoLibrary`) travels to the native
  implementations; `MethodChannelFilePickerAdapter` resolves it through
  `PickerSourceRouter` and accepts an explicit `host` (the iOS package
  pins `PickerHost.ios`). Tests in `test/media_source_routing_test.dart`.

## 7.3.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family ships at 7.3.0 together with the core.
- `zuraffa` dependency constraints unified to ^7.3.0; cross-family constraints move with the release.
- Fleet-wide `dependency_overrides: xml: 7.1.0`; README install guides refreshed to 7.3.0.

## 1.0.0

- First published release: typed file picking for the Zuraffa ecosystem,
  built on zuraffa ^6.2.2.
- Pure-Dart `FilePickerPort` (`pickFiles` / `saveFile` / `pickDirectory`)
  with a scripted in-memory default adapter so picker flows test without a
  platform; dismissal is an empty result / null path, never an exception.
- `FilePickerService` facade (typed `missing_allowed_extensions` error),
  `PickFilesUseCase` (Zuraffa use case with cancellation), and a
  `registerFilePickerDependencies(GetIt)` composition root with a
  platform port factory wired by the adapters at startup.
- Zorphy `PickedFile` entity (copyWith, equality, JSON).
- Federated platform adapters: `zuraffa_file_picker_android` (Storage
  Access Framework, cached copies for readable paths),
  `zuraffa_file_picker_ios` (UIDocumentPickerViewController, iOS 14+),
  `zuraffa_file_picker_macos` (NSOpenPanel / NSSavePanel, macOS 11+).

# Changelog

## 0.1.0

- Initial release.
- `FilePickerWire` vocabulary (method names, request keys, file
  descriptor keys) shared by every platform plugin.
- `ZuraffaFilePickerPlatform` platform interface with a safe
  dismissed-by-default fallback instance.
- `MethodChannelZuraffaFilePicker` client and
  `MethodChannelFilePickerAdapter` bridging onto the pure-Dart
  `FilePickerPort` (dismissal → empty result; malformed descriptor
  fields degrade to safe defaults).
