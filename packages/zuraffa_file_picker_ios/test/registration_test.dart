// Registration suite for the iOS adapter (spec 1205 FR-7: CI runs
// analyze + test for every federated member, so the adapter carries its
// dart-side registration behavior).
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa/zuraffa.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_ios/zuraffa_file_picker_ios.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ZuraffaFilePickerPlatform.instance = DefaultZuraffaFilePickerPlatform();
  });

  test('registerWith() binds the MethodChannel platform implementation', () {
    ZuraffaFilePickerIOS.registerWith();

    expect(
      ZuraffaFilePickerPlatform.instance,
      isA<MethodChannelZuraffaFilePicker>(),
    );
  });

  test('registerWith() wires the OS adapter as the default port', () {
    final getIt = GetIt.instance;
    getIt.reset();
    ZuraffaFilePickerIOS.registerWith();

    registerFilePickerDependencies(getIt);

    expect(getIt<FilePickerPort>(), isA<MethodChannelFilePickerAdapter>());
  });
}
