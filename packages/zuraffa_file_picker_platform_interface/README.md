# zuraffa_file_picker_platform_interface

The platform interface contract for
[zuraffa_file_picker](../zuraffa_file_picker/): the MethodChannel
protocol (`FilePickerWire` + `ZuraffaFilePickerPlatform`) and the
[MethodChannelFilePickerAdapter](../zuraffa_file_picker/) that bridges
native implementations onto the pure-Dart `FilePickerPort`.

You normally don't depend on this package directly — add the
app-facing package plus your platform package
(`zuraffa_file_picker_android/ios/macos`).
