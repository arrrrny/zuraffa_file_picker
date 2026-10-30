# zuraffa_file_picker_ios

The iOS implementation of
[zuraffa_file_picker](../zuraffa_file_picker/): two picker sources behind
the shared MethodChannel protocol (spec 002, issue #2):

| Source | Native picker | Serves |
| ------ | ------------- | ------ |
| `document` | `UIDocumentPickerViewController` | every file type; `allowedExtensions` honored exactly (the PDF invoice shape: `custom` + `['pdf']`) |
| `photoLibrary` | `PHPickerViewController` (iOS 14+) | `media` / `image` / `video` — the photo-library source `file_picker`'s `FileType.media` provides: the *whole* library (no "Recents only" trap), HEIC included, `allowedExtensions` advisory |

The Dart side resolves which source runs
([`PickerSourceRouter`](../zuraffa_file_picker/)) and sends it as the
explicit `source` key; the Swift plugin only switches on
`document` / `photoLibrary` and defaults to `document`.

Both sources copy what the user picked into app-accessible tmp storage,
so every descriptor carries a readable `path`, the picker's `name`, the
real byte `size` and a mime type derived from the name. A dismissed
picker resolves an empty result — cancellation is a value, never an
exception.

This package is endorsed by `zuraffa_file_picker` — add the app-facing
package plus this one and the OS picker is wired automatically at
startup:

```yaml
dependencies:
  zuraffa_file_picker: ^7.3.0
  zuraffa_file_picker_ios: ^7.3.0
```

Requires iOS 14+ (UniformTypeIdentifiers, PHPicker). No permission
strings are needed: the document picker grants access to the selected
files, and the photo source runs through the out-of-process
`PHPickerViewController`.
