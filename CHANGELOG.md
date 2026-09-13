# Changelog

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

## 0.1.0

- Initial release: typed file picking for the Zuraffa ecosystem.
- Pure-Dart `FilePickerPort` (`pickFiles` / `saveFile` / `pickDirectory`)
  with an in-memory default adapter so picker flows test without a platform.
- Federated platform adapters: `zuraffa_file_picker_android` (Storage
  Access Framework), `zuraffa_file_picker_ios` (UIDocumentPickerViewController),
  `zuraffa_file_picker_macos` (NSOpenPanel / NSSavePanel).
- `FilePickerService` facade, `PickFilesUseCase` (Zuraffa use case), and a
  `registerFilePickerDependencies(GetIt)` composition root.
