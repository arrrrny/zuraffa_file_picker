## 7.3.2 - 2026-10-31

Mono-version fleet alignment to 7.3.2: outbound send port lands in zuraffa_intents (shareText/shareFiles behind ShareIntentService); the whole family ships at one version.

## Unreleased

- The photo-library pick source on iOS (spec 002, issue #2):
  `PHPickerViewController` serves `media`/`image`/`video` (whole library,
  HEIC included, no permission string), `UIDocumentPickerViewController`
  keeps the document source with exact `allowedExtensions`. `registerWith`
  pins `PickerHost.ios`; both invoice shapes verified over the channel in
  `test/registration_test.dart`.

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

## 1.0.2

- Fix native compilation errors: derive the MIME type from the picked
  file's content type (`URL.resourceValues(.contentTypeKey)` —
  `UTType(url:)` does not exist), correct `lowercased()`, and drop the
  redundant `allowedContentTypes` assignment (iOS export picker types are
  fixed by the `forExporting` initializer). Compile-validated via a
  consumer app build on iOS simulator and macOS.

## 1.0.1

- Fix the in-family `zuraffa_file_picker_platform_interface` constraint to
  `^1.0.0` — the published 1.0.0 (`^0.1.0` admitted no released version)
  made this package unresolvable for consumers.

## 0.1.0

- Initial release: platform implementation of `zuraffa_file_picker`
  behind the shared `zuraffa_file_picker_platform_interface` protocol.
