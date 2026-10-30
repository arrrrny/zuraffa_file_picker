// Registration suite for the iOS adapter (spec 1205 FR-7: CI runs
// analyze + test for every federated member, so the adapter carries its
// dart-side registration behavior).
//
// Spec 002 media-source routing: registerWith() pins the ios host so the
// MethodChannel adapter resolves `media` to the photo library, and the
// two invoice shapes travel over the real channel the Swift plugin
// serves (PHPicker for the photo shape, UIDocumentPicker for the PDF
// shape).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa/zuraffa.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_ios/zuraffa_file_picker_ios.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

/// The PDF invoice shape of zik_zak's `uploadInvoice`.
const _pdfInvoiceOptions = FilePickOptions(
  type: FileType.custom,
  allowedExtensions: ['pdf'],
);

/// The photo invoice shape of zik_zak's `uploadInvoice`.
const _photoInvoiceOptions = FilePickOptions(
  type: FileType.media,
  allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ZuraffaFilePickerPlatform.instance = DefaultZuraffaFilePickerPlatform();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel, null);
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

  group('media-source routing (spec 002, iOS host)', () {
    late GetIt getIt;

    setUp(() {
      getIt = GetIt.asNewInstance();
      ZuraffaFilePickerIOS.registerWith();
      registerFilePickerDependencies(getIt);
    });

    test('the registered port is pinned to the ios host', () {
      expect(
        (getIt<FilePickerPort>() as MethodChannelFilePickerAdapter).host,
        PickerHost.ios,
        reason: 'the photo-library routing is an iOS-only capability',
      );
    });

    test('the photo invoice shape routes to the photo library on the channel',
        () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel,
              (call) async {
        calls.add(call);
        return null; // the user dismissed the picker
      });

      final result = await getIt<FilePickerPort>().pickFiles(
        _photoInvoiceOptions,
      );

      expect(calls.single.method, 'pickFiles');
      final sent = calls.single.arguments as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'photoLibrary');
      expect(sent[FilePickerWire.type], 'media');
      expect(
        sent[FilePickerWire.allowedExtensions],
        ['jpg', 'jpeg', 'png', 'heic'],
      );
      // A dismissed PHPicker resolves empty — cancellation is a value.
      expect(result.isCanceled, isTrue);
      expect(result.files, isEmpty);
    });

    test('the PDF invoice shape routes to the document picker on the channel',
        () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel,
              (call) async {
        calls.add(call);
        return null;
      });

      final result = await getIt<FilePickerPort>().pickFiles(
        _pdfInvoiceOptions,
      );

      final sent = calls.single.arguments as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'document');
      expect(sent[FilePickerWire.allowedExtensions], ['pdf']);
      expect(result.isCanceled, isTrue);
    });

    test('a heic descriptor from the photo source becomes a full PickedFile',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel,
              (call) async {
        return [
          {
            FilePickerWire.path:
                '/tmp/zuraffa_file_picker/IMG_0001.heic',
            FilePickerWire.name: 'IMG_0001.heic',
            FilePickerWire.size: 2457600,
            FilePickerWire.mimeType: 'image/heic',
          },
        ];
      });

      final result = await getIt<FilePickerPort>().pickFiles(
        _photoInvoiceOptions,
      );

      final file = result.files.single;
      expect(file.path, '/tmp/zuraffa_file_picker/IMG_0001.heic');
      expect(file.name, 'IMG_0001.heic');
      expect(file.size, 2457600);
      expect(file.mimeType, 'image/heic');
      expect(result.isCanceled, isFalse);
    });
  });
}

