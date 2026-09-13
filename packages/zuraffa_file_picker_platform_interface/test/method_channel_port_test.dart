// Behavioral suite for the platform interface contract.
//
// Wire vocabulary · default fallback · instance registry ·
// MethodChannel client · adapter wire-to-domain bridge.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

/// A scripted platform: records every request and replies from maps the
/// tests prepare.
class _ScriptedFilePickerPlatform extends ZuraffaFilePickerPlatform {
  List<Map<Object?, Object?>>? pickReply;
  String? saveReply;
  String? directoryReply;

  final receivedMethods = <String>[];
  final receivedArgs = <Object?>[];

  @override
  Future<List<Map<Object?, Object?>>?> pickFiles(
    Map<Object?, Object?> options,
  ) async {
    receivedMethods.add(FilePickerWire.pickFiles);
    receivedArgs.add(options);
    return pickReply;
  }

  @override
  Future<String?> saveFile(Map<Object?, Object?> options) async {
    receivedMethods.add(FilePickerWire.saveFile);
    receivedArgs.add(options);
    return saveReply;
  }

  @override
  Future<String?> pickDirectory(String? initialDirectory) async {
    receivedMethods.add(FilePickerWire.pickDirectory);
    receivedArgs.add(initialDirectory);
    return directoryReply;
  }
}

Map<Object?, Object?> _descriptor({
  String path = '/tmp/a.png',
  String name = 'a.png',
  Object? size = 128,
  Object? mimeType = 'image/png',
}) => {
  FilePickerWire.path: path,
  FilePickerWire.name: name,
  FilePickerWire.size: size,
  FilePickerWire.mimeType: mimeType,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ZuraffaFilePickerPlatform.instance = DefaultZuraffaFilePickerPlatform();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel, null);
  });

  group('wire vocabulary (FR-001)', () {
    test('method names are the three picker operations', () {
      expect(FilePickerWire.pickFiles, 'pickFiles');
      expect(FilePickerWire.saveFile, 'saveFile');
      expect(FilePickerWire.pickDirectory, 'pickDirectory');
    });

    test('request keys cover every option field', () {
      expect(FilePickerWire.type, 'type');
      expect(FilePickerWire.allowedExtensions, 'allowedExtensions');
      expect(FilePickerWire.multiple, 'multiple');
      expect(FilePickerWire.initialDirectory, 'initialDirectory');
      expect(FilePickerWire.fileName, 'fileName');
      expect(FilePickerWire.bytes, 'bytes');
    });

    test('descriptor keys cover every picked-file field', () {
      expect(FilePickerWire.path, 'path');
      expect(FilePickerWire.name, 'name');
      expect(FilePickerWire.size, 'size');
      expect(FilePickerWire.mimeType, 'mimeType');
    });
  });

  group('platform instance registry', () {
    test('defaults to the dismissed fallback', () async {
      expect(
        ZuraffaFilePickerPlatform.instance,
        isA<DefaultZuraffaFilePickerPlatform>(),
      );
      expect(
        await ZuraffaFilePickerPlatform.instance.pickFiles(const {}),
        isNull,
      );
      expect(
        await ZuraffaFilePickerPlatform.instance.saveFile(const {}),
        isNull,
      );
      expect(
        await ZuraffaFilePickerPlatform.instance.pickDirectory(null),
        isNull,
      );
    });

    test('platform packages swap the instance at registration', () async {
      final scripted = _ScriptedFilePickerPlatform();
      ZuraffaFilePickerPlatform.instance = scripted;
      expect(identical(ZuraffaFilePickerPlatform.instance, scripted), isTrue);
    });
  });

  group('MethodChannel client', () {
    test('sends the method name and serialized options once', () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel, (
            call,
          ) async {
            calls.add(call);
            return null;
          });
      final client = MethodChannelZuraffaFilePicker();
      await client.pickFiles(const {
        FilePickerWire.type: 'image',
        FilePickerWire.multiple: true,
      });
      expect(calls.single.method, 'pickFiles');
      expect(calls.single.arguments, isA<Map<Object?, Object?>>());
      expect(
        (calls.single.arguments as Map)[FilePickerWire.type],
        'image',
      );
    });

    test('a descriptor list survives the codec as descriptor maps',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel, (
            call,
          ) async {
            return [_descriptor()];
          });
      final raw = await MethodChannelZuraffaFilePicker().pickFiles(const {});
      expect(raw, isNotNull);
      expect(raw!.single[FilePickerWire.name], 'a.png');
    });

    test('saveFile and pickDirectory round-trip nullable paths', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaFilePicker.channel, (
            call,
          ) async {
            if (call.method == FilePickerWire.saveFile) return '/tmp/out.pdf';
            if (call.arguments != null) return call.arguments as String;
            return null;
          });
      final client = MethodChannelZuraffaFilePicker();
      expect(await client.saveFile(const {}), '/tmp/out.pdf');
      expect(await client.pickDirectory('/tmp/docs'), '/tmp/docs');
      expect(await client.pickDirectory(null), isNull);
    });
  });

  group('adapter wire-to-domain bridge', () {
    test('serializes every pick option onto the wire', () async {
      final scripted = _ScriptedFilePickerPlatform()..pickReply = null;
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      await adapter.pickFiles(
        const FilePickOptions(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'png'],
          multiple: true,
          initialDirectory: '/tmp',
        ),
      );
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.type], 'custom');
      expect(sent[FilePickerWire.allowedExtensions], ['pdf', 'png']);
      expect(sent[FilePickerWire.multiple], isTrue);
      expect(sent[FilePickerWire.initialDirectory], '/tmp');
    });

    test('maps every FileType onto its wire name', () async {
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      for (final type in FileType.values) {
        await adapter.pickFiles(FilePickOptions(type: type));
        expect(
          (scripted.receivedArgs.last as Map)[FilePickerWire.type],
          type.name,
        );
      }
    });

    test('a dismissed picker becomes the canceled result', () async {
      final adapter = MethodChannelFilePickerAdapter(
        platform: _ScriptedFilePickerPlatform(),
      );
      final result = await adapter.pickFiles(const FilePickOptions());
      expect(result.isCanceled, isTrue);
      expect(result.files, isEmpty);
    });

    test('descriptors become PickedFile entities', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..pickReply = [_descriptor()];
      final result = await MethodChannelFilePickerAdapter(
        platform: scripted,
      ).pickFiles(const FilePickOptions());
      final file = result.files.single;
      expect(file.path, '/tmp/a.png');
      expect(file.name, 'a.png');
      expect(file.size, 128);
      expect(file.mimeType, 'image/png');
    });

    test('malformed descriptor fields degrade to safe defaults', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..pickReply = [
          _descriptor(size: '512', mimeType: null),
          {
            FilePickerWire.path: '/tmp/b.pdf',
            FilePickerWire.size: 'not-a-number',
          },
        ];
      final result = await MethodChannelFilePickerAdapter(
        platform: scripted,
      ).pickFiles(const FilePickOptions());
      expect(result.files[0].size, 512);
      expect(result.files[0].mimeType, isNull);
      expect(result.files[1].name, '');
      expect(result.files[1].size, 0);
    });

    test('saveFile forwards options and returns the path', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..saveReply = '/tmp/out.pdf';
      final path = await MethodChannelFilePickerAdapter(
        platform: scripted,
      ).saveFile(
        const FileSaveOptions(fileName: 'out.pdf', initialDirectory: '/tmp'),
      );
      expect(path, '/tmp/out.pdf');
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.fileName], 'out.pdf');
      expect(sent[FilePickerWire.initialDirectory], '/tmp');
      expect(sent.containsKey(FilePickerWire.bytes), isFalse);
    });

    test('saveFile forwards bytes when provided', () async {
      final scripted = _ScriptedFilePickerPlatform()..saveReply = '/tmp/out';
      await MethodChannelFilePickerAdapter(platform: scripted).saveFile(
        FileSaveOptions(fileName: 'out', bytes: Uint8List.fromList([1, 2, 3])),
      );
      final sent = scripted.receivedArgs.single as Map<Object?, Object?>;
      expect(sent[FilePickerWire.bytes], isA<Uint8List>());
    });

    test('pickDirectory delegates to the platform', () async {
      final scripted = _ScriptedFilePickerPlatform()
        ..directoryReply = '/tmp/docs';
      final path = await MethodChannelFilePickerAdapter(
        platform: scripted,
      ).pickDirectory(initialDirectory: '/tmp');
      expect(scripted.receivedMethods.single, FilePickerWire.pickDirectory);
      expect(scripted.receivedArgs.single, '/tmp');
      expect(path, '/tmp/docs');
    });

    test('constructor-supplied platform wins; default consults the registry',
        () async {
      final scripted = _ScriptedFilePickerPlatform();
      final adapter = MethodChannelFilePickerAdapter(platform: scripted);
      expect(identical(adapter.platform, scripted), isTrue);

      final registered = _ScriptedFilePickerPlatform();
      ZuraffaFilePickerPlatform.instance = registered;
      expect(
        identical(
          MethodChannelFilePickerAdapter().platform,
          registered,
        ),
        isTrue,
      );
    });
  });
}
