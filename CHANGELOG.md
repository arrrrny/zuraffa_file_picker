## Unreleased

- Fleet hardening (zik_zak spec 1205): new CI workflow (`.github/workflows/test.yml`) runs analyze + test + publish dry-run for every federated member on every push/PR — one job per member so a failure names it. Single ubuntu lane: nothing in the fleet's Dart code is platform-conditional.
- Publish verification: the sibling-checkout `zuraffa` path overrides are gone from the member pubspecs (and the example app) so a fresh clone or CI resolves against the published fleet at 7.3.0; pub ignores overrides when publishing, so shipped artifacts are unchanged.
- README parity: platform support matrix, install snippet pinned to the fleet version, and an adoption status note (healthy but unconsumed; what would justify re-adoption into zik_zak).
- The member package CHANGELOGs now carry the 7.3.0 entry (the mono-release propagation had never landed on master), clearing the `pub publish --dry-run` validation warning on every member.
- Registration suites for the android/ios/macos adapters so every member carries tests, and a fleet consistency test pinning mono-version/constraint/README/CI parity.

## 7.3.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family ships at 7.3.0 together with the core.
- `zuraffa` dependency constraints unified to ^7.3.0; cross-family constraints move with the release.
- Fleet-wide `dependency_overrides: xml: 7.1.0`; README install guides refreshed to 7.3.0.

## 7.2.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family now ships at the same version as the core.
- `zuraffa` dependency constraint unified to ^7.2.0 across the fleet.
- zuraffa_storage now wraps the maintained `zuraffa_minio` fork instead of the abandoned `minio` package (xml 7 compatible).
- Fleet-wide `dependency_overrides: xml: 7.1.0` policy; README install guides refreshed to the release version.

# Changelog

## Unreleased

- Media-source pick on iOS (spec 002, issue #2): `FileType.media` on iOS now
  opens the photo library (`PHPickerViewController`) — the `file_picker`
  `FileType.media` semantics zik_zak's price-check invoice flow depends on.
- The routing lives in `PickerSourceRouter` (pure Dart, over
  type/requested source/host) and travels to the native side as the
  explicit `source` wire key; `FilePickOptions` gains a `PickerSource`
  field (`auto` default) to pin a source explicitly.
- Extension-filter parity: document source honors `allowedExtensions`
  exactly; photo source filters by kind and documents its producible
  extensions (`heic` included). `PickedFile` population parity (real byte
  size, name-derived mime, app-accessible path) and the cancellation
  contract pinned by tests for both invoice shapes.

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

## 0.1.0

- Initial release: typed file picking for the Zuraffa ecosystem.
- Pure-Dart `FilePickerPort` (`pickFiles` / `saveFile` / `pickDirectory`)
  with an in-memory default adapter so picker flows test without a platform.
- Federated platform adapters: `zuraffa_file_picker_android` (Storage
  Access Framework), `zuraffa_file_picker_ios` (UIDocumentPickerViewController),
  `zuraffa_file_picker_macos` (NSOpenPanel / NSSavePanel).
- `FilePickerService` facade, `PickFilesUseCase` (Zuraffa use case), and a
  `registerFilePickerDependencies(GetIt)` composition root.
