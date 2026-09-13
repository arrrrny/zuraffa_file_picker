# zuraffa_file_picker_android

The Android implementation of
[zuraffa_file_picker](../zuraffa_file_picker/): the Storage Access
Framework document picker (ACTION_OPEN_DOCUMENT /
ACTION_CREATE_DOCUMENT / ACTION_OPEN_DOCUMENT_TREE) behind the shared
MethodChannel protocol.

This package is endorsed by `zuraffa_file_picker` — add the app-facing
package plus this one and the OS picker is wired automatically at
startup:

```yaml
dependencies:
  zuraffa_file_picker: ^0.1.0
  zuraffa_file_picker_android: ^0.1.0
```

Picked documents are copied into the app cache so the returned
descriptor always carries a readable filesystem path; no storage
permission is required (the system document picker grants access).
