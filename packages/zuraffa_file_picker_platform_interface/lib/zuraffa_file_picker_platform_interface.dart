/// zuraffa_file_picker_platform_interface — the MethodChannel protocol
/// every `zuraffa_file_picker` platform package implements, plus the
/// [MethodChannelFilePickerAdapter] that bridges the native wire
/// vocabulary onto the app-facing pure-Dart `FilePickerPort`.
///
/// Platform packages typically re-export this barrel and register
/// `MethodChannelZuraffaFilePicker` as the platform instance from their
/// `registerWith()`.
library;

export 'src/file_picker_platform_interface.dart';
export 'src/method_channel_file_picker_adapter.dart';
export 'src/method_channel_zuraffa_file_picker.dart';
