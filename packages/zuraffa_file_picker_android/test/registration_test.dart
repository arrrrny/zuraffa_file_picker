// Registration suite for the Android adapter (spec 1205 FR-7: CI runs
// analyze + test for every federated member, so the adapter carries its
// dart-side registration behavior).
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa/zuraffa.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_android/zuraffa_file_picker_android.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ZuraffaFilePickerPlatform.instance = DefaultZuraffaFilePickerPlatform();
  });

  test('registerWith() binds the MethodChannel platform implementation', () {
    ZuraffaFilePickerAndroid.registerWith();

    expect(
      ZuraffaFilePickerPlatform.instance,
      isA<MethodChannelZuraffaFilePicker>(),
    );
  });

  test('registerWith() wires the OS adapter as the default port', () {
    final getIt = GetIt.instance;
    getIt.reset();
    ZuraffaFilePickerAndroid.registerWith();

    registerFilePickerDependencies(getIt);

    expect(getIt<FilePickerPort>(), isA<MethodChannelFilePickerAdapter>());
  });
}
