import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

/// The macOS entrypoint: registers the MethodChannel implementation with
/// the shared platform interface so `MethodChannelFilePickerAdapter` routes
/// to the Swift plugin, and wires the real [FilePickerPort] so any app
/// depending on this package gets the OS file picker by default.
class ZuraffaFilePickerMacOS {
  static void registerWith() {
    ZuraffaFilePickerPlatform.instance = MethodChannelZuraffaFilePicker();
    setPlatformFilePickerPortFactory(() => MethodChannelFilePickerAdapter());
  }
}
