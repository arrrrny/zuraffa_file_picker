# 001 — File Picker Port

## Why

Issue [#674](https://github.com/arrrrny/zuraffa/issues/674) (part of EPIC
[#214](https://github.com/arrrrny/zuraffa/issues/214), [v6] migrate all
ZikZak pub.dev packages onto zuraffa): `zuraffa_file_picker` becomes a
complete federated plugin built on the Zuraffa framework, following the
`zuraffa_permissions` / `zuraffa_auth` monorepo pattern.

## FRs

- **FR-001** — `FilePickerPort`: the technology-agnostic contract
  (`pickFiles` / `saveFile` / `pickDirectory`). Consumers program against
  the port; platform adapters implement it. Cancelation is expressed as an
  empty `FilePickResult` / `null` — never an exception.
- **FR-002** — Entities are Zuraffa (Zorphy) entities: `PickedFile`
  (path/name/size/mimeType) with copyWith, equality and JSON.
- **FR-003** — Business logic flows through a Zuraffa use case
  (`PickFilesUseCase`) resolvable from GetIt.
- **FR-004** — `FileType` selects the picker filter: any, media, image,
  video, audio, custom (custom requires `allowedExtensions` — typed error
  otherwise).
- **FR-005** — The in-memory default adapter scripts outcomes so every
  picker flow tests in pure Dart, without a platform.
- **FR-006** — Federation: `zuraffa_file_picker_platform_interface` holds
  the MethodChannel protocol + a safe canceled-by-default fallback; the
  `_android` / `_ios` / `_macos` siblings `implements:` the app-facing
  package and self-register at startup (`registerWith` sets the platform
  instance + the port factory).
- **FR-007** — `registerFilePickerDependencies(GetIt)` wires the whole
  stack (port, service, use case) in one call.

## Verification

- `packages/zuraffa_file_picker/test/file_picker_test.dart` — port, adapter
  state machine, service, DI wiring, use case, entities (pure Dart).
- `packages/zuraffa_file_picker_platform_interface/test/method_channel_port_test.dart`
  — wire vocabulary, default fallback, MethodChannel client, adapter bridge.
