# Changelog

## 0.1.0

- Initial release.
- `FilePickerWire` vocabulary (method names, request keys, file
  descriptor keys) shared by every platform plugin.
- `ZuraffaFilePickerPlatform` platform interface with a safe
  dismissed-by-default fallback instance.
- `MethodChannelZuraffaFilePicker` client and
  `MethodChannelFilePickerAdapter` bridging onto the pure-Dart
  `FilePickerPort` (dismissal → empty result; malformed descriptor
  fields degrade to safe defaults).
