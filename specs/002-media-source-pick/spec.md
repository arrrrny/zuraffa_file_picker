# 002 — Media-Source Pick + Invoice-Flow Parity

## Why

Issue [#2](https://github.com/arrrrny/zuraffa_file_picker/issues/2): zik_zak
spec 1206 (`specs/1206-readopt-fleet-packages`, `arrrrny/zik_zak`) migrates
its price-check invoice upload (`price_check_invoice_controller.dart`,
`uploadInvoice`) onto this package. That call site runs exactly two shapes:

- **PDF invoices** — `FileType.custom` + `allowedExtensions: ['pdf']`
- **Photo invoices** — `FileType.media` + `allowedExtensions:
  ['jpg','jpeg','png','heic']` — deliberately routed to the **photo-library
  source** on iOS (the document picker's "Recents only" trap is exactly what
  that routing avoids)

Spec 001 shipped `UIDocumentPickerViewController` only on iOS, so `media`
opened the document picker: the one capability gap blocking adoption.

## FRs

- **FR-1** — A photo-library-backed picker source on iOS
  (`PHPickerViewController`) with the semantics `file_picker`'s
  `FileType.media` provides: the whole library (no "Recents only" trap),
  images/videos/live photos, no permission string, HEIC included. The
  routing lives in one place, [`PickerSourceRouter`] — a pure Dart function
  over (type, requested source, host) — and travels to the native side as
  the explicit `source` wire key; the Swift plugin switches on
  `document` / `photoLibrary` and defaults to `document`. `media`,
  `image` and `video` resolve to the photo library on iOS; `any`, `audio`
  and `custom` stay on the document picker; an explicit `photoLibrary`
  request for a type the library cannot serve (custom documents, standalone
  audio) degrades to the document picker; hosts without a photo source
  (Android, macOS) always document.
- **FR-2** — Extension-filter parity: the document source honors
  `allowedExtensions` exactly (`custom` + `['pdf']` →
  `UTType(filenameExtension: 'pdf')`); the photo source filters by *kind*
  and treats extensions as advisory, like `file_picker`, and the
  router's `photoLibraryExtensions` documents which extensions a photo
  pick can produce — `heic` included (the invoice flow depends on it).
- **FR-3** — `PickedFile` population parity from both sources: `path` is an
  app-accessible copy (the photo source copies each item's file
  representation into tmp inside the load completion — the representation
  URL is only valid there), `name` is the picker's name, `size` is the
  real byte size (the original file, never a transcoded placeholder or a
  zero), and `mimeType` is derived from the name, `null` when
  undeterminable.
- **FR-4** — Cancellation contract pinned end to end: a dismissed picker
  (document or photo source) resolves an empty `FilePickResult`
  (`isCanceled`) — never an exception — through the in-memory adapter, the
  MethodChannel adapter and the iOS registration seam.
- **FR-5** — Everything above tests platform-less: route resolution,
  wire serialization and descriptor population in pure Dart / Flutter
  tests; the iOS registration seam pins the `ios` host and the full
  channel round trip.

## Verification

- `packages/zuraffa_file_picker/test/media_source_test.dart` — router
  table, photo-library extension coverage, `FilePickOptions.source`, both
  invoice shapes + cancellation through the in-memory adapter.
- `packages/zuraffa_file_picker_platform_interface/test/media_source_routing_test.dart`
  — `source` wire key, adapter resolution per host + explicit requests,
  descriptor field population, MethodChannel cancellation.
- `packages/zuraffa_file_picker_ios/test/registration_test.dart` — the
  registered port pinned to the iOS host; both invoice shapes over the
  real `zuraffa_file_picker` channel; a HEIC descriptor becomes a full
  `PickedFile`.
- Swift: `SwiftZuraffaFilePickerPlugin` gains the `PHPickerViewController`
  delegate (photo source), verified by parse (`xcrun swiftc -parse`) —
  the interactive surface needs a simulator run of
  `packages/zuraffa_file_picker/example`.
