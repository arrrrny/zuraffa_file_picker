# Changelog

## 0.1.0

- Initial release: typed file picking for the Zuraffa ecosystem.
- Pure-Dart `FilePickerPort` (`pickFiles` / `saveFile` / `pickDirectory`)
  with an in-memory default adapter so picker flows test without a platform.
- Federated platform adapters: `zuraffa_file_picker_android` (Storage
  Access Framework), `zuraffa_file_picker_ios` (UIDocumentPickerViewController),
  `zuraffa_file_picker_macos` (NSOpenPanel / NSSavePanel).
- `FilePickerService` facade, `PickFilesUseCase` (Zuraffa use case), and a
  `registerFilePickerDependencies(GetIt)` composition root.
