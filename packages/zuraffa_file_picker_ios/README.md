# zuraffa_file_picker_ios

The iOS implementation of
[zuraffa_file_picker](../zuraffa_file_picker/):
UIDocumentPickerViewController (file picking with `asCopy` snapshots,
document export, folder selection) behind the shared MethodChannel
protocol.

This package is endorsed by `zuraffa_file_picker` — add the app-facing
package plus this one and the OS picker is wired automatically at
startup:

```yaml
dependencies:
  zuraffa_file_picker: ^0.1.0
  zuraffa_file_picker_ios: ^0.1.0
```

Requires iOS 14+ (UniformTypeIdentifiers). No permission strings are
needed: the system document picker grants access to the files the user
selects.
