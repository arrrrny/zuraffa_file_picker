// Behavioral suite for spec 002-media-source-pick (issue #2) — the wire
// layer: the resolved source travels to the native side, both invoice
// shapes serialize correctly, and the descriptor contract holds.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

/// A scripted platform: records every request and replies from maps the
/// tests prepare.
class _ScriptedFilePickerPlatform extends ZuraffaFilePickerPlatform {
  List<Map<Object?, Object?>>? pickReply;
  final receivedArgs = <Object?>[];

  @override
  Future<List<Map<Object?, Object?>>?> pickFiles(
    Map<Object?, Object?> options,
  ) async {
    receivedArgs.add(options);
    return pickReply;
  }

  @override
  Future<String?> saveFile(Map<Object?, Object?> options) async => null;

  @override
  Future<String?> pickDirectory(String? initialDirectory) async => null;
}

Map<Object?, Object?> _descriptor({
  String path = '/tmp/a.heic',
  String name = 'a.heic',
  Object? size = 2457600,
  Object? mimeType = 'image/heic',
}) => {
  FilePickerWire.path: path,
  FilePickerWire.name: name,
  FilePickerWire.size: size,
  FilePickerWire.mimeType: mimeType,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    ZuraffaFilePickerPlatform.instance = DefaultZuraffaFilePickerPlatform();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel, null);
  });

  group('wire vocabulary (spec 002 FR-1)', () {
    test('the source key carries the resolved PickerSource', () {
      expect(FilePickerWire.source, 'source');
    });
  });

  group('adapter source resolution', () {
    test('the ios host resolves media to the photo library on the wire',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      await adapter.pickFiles(
        const FilePickOptions(
          type: FileType.media,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
        ),
      );
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'photoLibrary');
      expect(sent[FilePickerWire.type], 'media');
      expect(sent[FilePickerWire.allowedExtensions],
          ['jpg', 'jpeg', 'png', 'heic']);
    });

    test('the ios host keeps custom+pdf on the document picker', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      await adapter.pickFiles(
        const FilePickOptions(type: FileType.custom, allowedExtensions: ['pdf']),
      );
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'document');
      expect(sent[FilePickerWire.allowedExtensions], ['pdf']);
    });

    test('an explicit document request overrides the auto photo routing',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      await adapter.pickFiles(
        const FilePickOptions(
          type: FileType.media,
          source: PickerSource.document,
        ),
      );
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'document');
    });

    test('an explicit photoLibrary request travels unresolved', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      await adapter.pickFiles(
        const FilePickOptions(
          type: FileType.image,
          source: PickerSource.photoLibrary,
        ),
      );
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'photoLibrary');
    });

    test('non-ios hosts resolve the media shape to the document picker',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      await adapter.pickFiles(const FilePickOptions(type: FileType.media));
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'document');
    });

    test('an explicit host wins over the ambient platform', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(
        platform: scripted,
        host: PickerHost.ios,
      );
      await adapter.pickFiles(const FilePickOptions(type: FileType.media));
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.source], 'photoLibrary');
    });
  });

  group('descriptor field population (spec 002 FR-3)', () {
    test('a large PDF descriptor keeps its real byte size', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..pickReply = [
          {
            FilePickerWire.path: '/tmp/invoice-1.pdf',
            FilePickerWire.name: 'invoice-1.pdf',
            FilePickerWire.size: 5242880,
            FilePickerWire.mimeType: 'application/pdf',
          },
        ];
      final result = await MethodChannelFilePickerAdapter(
        platform: scripted,
      ).pickFiles(
        const FilePickOptions(type: FileType.custom, allowedExtensions: ['pdf']),
      );
      final file = result.files.single;
      expect(file.path, '/tmp/invoice-1.pdf');
      expect(file.name, 'invoice-1.pdf');
      expect(file.size, 5242880);
      expect(file.mimeType, 'application/pdf');
    });

    test('a heic photo descriptor carries name, bytes and mime', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..pickReply = [_descriptor()];
      final result = await MethodChannelFilePickerAdapter(
        platform: scripted,
        host: PickerHost.ios,
      ).pickFiles(const FilePickOptions(type: FileType.media));
      final file = result.files.single;
      expect(file.path, '/tmp/a.heic');
      expect(file.name, 'a.heic');
      expect(file.size, 2457600);
      expect(file.mimeType, 'image/heic');
    });

    test('a missing mime degrades to null without crashing', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..pickReply = [
          {
            FilePickerWire.path: '/tmp/a.pdf',
            FilePickerWire.name: 'a.pdf',
            FilePickerWire.size: 1024,
          },
        ];
      final result = await MethodChannelFilePickerAdapter(
        platform: scripted,
      ).pickFiles(const FilePickOptions());
      expect(result.files.single.mimeType, isNull);
      expect(result.files.single.size, 1024);
    });
  });

  group('cancellation through the MethodChannel client (spec 002 FR-4)',
      () {
    test('a dismissed native picker is the canceled result for both shapes',
        () async {
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      final pdfResult = await adapter.pickFiles(
        const FilePickOptions(type: FileType.custom, allowedExtensions: ['pdf']),
      );
      final photoResult = await adapter.pickFiles(
        const FilePickOptions(
          type: FileType.media,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
        ),
      );
      expect(pdfResult.isCanceled, isTrue);
      expect(pdfResult.files, isEmpty);
      expect(photoResult.isCanceled, isTrue);
      expect(photoResult.files, isEmpty);
    });

    test('the channel client surfaces a null reply as null (never throws)',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel,
              (call) async => null);
      final raw = await MethodChannelZuraffaFilePicker().pickFiles(const {
        FilePickerWire.source: 'photoLibrary',
        FilePickerWire.type: 'media',
      });
      expect(raw, isNull);
    });
  });
}
