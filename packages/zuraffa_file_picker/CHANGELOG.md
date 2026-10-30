## Unreleased

- Media-source pick on iOS (spec 002, issue #2): iOS `FileType.media`
  resolves to the photo library through `PickerSourceRouter`
  (`FilePickOptions.source` added, default `auto`); both
  `uploadInvoice` shapes (custom+pdf, media+jpg/jpeg/png/heic), field
  population and the cancellation contract pinned by
  `test/media_source_test.dart`.

## 7.3.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family ships at 7.3.0 together with the core.
- `zuraffa` dependency constraints unified to ^7.3.0; cross-family constraints move with the release.
- Fleet-wide `dependency_overrides: xml: 7.1.0`; README install guides refreshed to 7.3.0.

## 1.0.1

- `zuraffa` constraint raised to `^7.0.0` and `zorphy_annotation` to `^2.4.3`,
  so the package resolves alongside zuraffa 7.x consumers. No API changes.

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

- Initial release: typed file picking for the Zuraffa ecosystem.
- Pure-Dart `FilePickerPort` (`pickFiles` / `saveFile` / `pickDirectory`)
  with an in-memory default adapter so picker flows test without a platform.
- `FilePickerService` facade, `PickFilesUseCase` (Zuraffa use case), and a
  `registerFilePickerDependencies(GetIt)` composition root.
- Zorphy entities: `PickedFile` with copyWith, equality and JSON.
