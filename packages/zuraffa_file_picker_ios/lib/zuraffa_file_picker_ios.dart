import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

/// The iOS entrypoint: registers the MethodChannel implementation with
/// the shared platform interface so `MethodChannelFilePickerAdapter`
/// routes to the Swift plugin, and wires the real [FilePickerPort] so
/// any app depending on this package gets the OS file picker by default.
class ZuraffaFilePickerIOS {
  static void registerWith() {
    ZuraffaFilePickerPlatform.instance = MethodChannelZuraffaFilePicker();
    // Pin the ios host (spec 002): the Swift plugin serves *two* pickers —
    // UIDocumentPickerViewController for the document source and
    // PHPickerViewController for the photo-library source — and the port
    // must resolve `media`/`image`/`video` to the photo library whatever
    // the test host's ambient defaultTargetPlatform is.
    setPlatformFilePickerPortFactory(
      () => MethodChannelFilePickerAdapter(host: PickerHost.ios),
    );
  }
}
