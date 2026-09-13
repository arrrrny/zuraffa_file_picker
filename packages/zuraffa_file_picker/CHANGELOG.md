# Changelog

## 0.1.0

- Initial release: typed file picking for the Zuraffa ecosystem.
- Pure-Dart `FilePickerPort` (`pickFiles` / `saveFile` / `pickDirectory`)
  with an in-memory default adapter so picker flows test without a platform.
- `FilePickerService` facade, `PickFilesUseCase` (Zuraffa use case), and a
  `registerFilePickerDependencies(GetIt)` composition root.
- Zorphy entities: `PickedFile` with copyWith, equality and JSON.
