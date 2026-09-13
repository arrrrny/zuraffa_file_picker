# zuraffa_file_picker_macos

The macOS implementation of
[zuraffa_file_picker](../zuraffa_file_picker/): NSOpenPanel and
NSSavePanel behind the shared MethodChannel protocol.

This package is endorsed by `zuraffa_file_picker` — add the app-facing
package plus this one and the OS picker is wired automatically at
startup:

```yaml
dependencies:
  zuraffa_file_picker: ^0.1.0
  zuraffa_file_picker_macos: ^0.1.0
```

Requires macOS 11+ (UniformTypeIdentifiers). Sandboxed apps work out of
the box for user-selected files: add the
`com.apple.security.files.user-selected.read-only` (and `.read-write`
for save flows) entitlement to your entitlements plist.
