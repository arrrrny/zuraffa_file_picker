// Behavioral suite for spec 001-file-picker-port — pure Dart, no Flutter.
//
// FR-001 port contract · FR-002 entities · FR-003 use case ·
// FR-004 file type · FR-005 in-memory adapter · FR-007 DI wiring.
import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

PickedFile _file(String name) => PickedFile(
  path: '/tmp/$name',
  name: name,
  size: 128,
  mimeType: 'application/octet-stream',
);

void main() {
  group('file type enum (FR-004)', () {
    test('exposes exactly the six built-in filters', () {
      expect(
        FileType.values.map((t) => t.name),
        ['any', 'media', 'image', 'video', 'audio', 'custom'],
      );
    });
  });

  group('picked-file entity (FR-002)', () {
    test('carries path, name, size and an optional mime type', () {
      final file = PickedFile(
        path: '/tmp/a.png',
        name: 'a.png',
        size: 128,
        mimeType: 'image/png',
      );
      expect(file.path, '/tmp/a.png');
      expect(file.name, 'a.png');
      expect(file.size, 128);
      expect(file.mimeType, 'image/png');
      expect(
        PickedFile(path: '/tmp/a.bin', name: 'a.bin', size: 1).mimeType,
        isNull,
      );
    });

    test('copyWith replaces only the given fields', () {
      final file = _file('a.png');
      final renamed = file.copyWith(name: 'b.png');
      expect(renamed.name, 'b.png');
      expect(renamed.path, file.path);
      expect(renamed.size, file.size);
    });

    test('equality and hashCode follow the fields', () {
      expect(_file('a.png'), equals(_file('a.png')));
      expect(_file('a.png'), isNot(equals(_file('b.png'))));
      expect(
        _file('a.png').hashCode,
        equals(_file('a.png').hashCode),
      );
    });

    test('JSON round-trips', () {
      final file = PickedFile(
        path: '/tmp/a.png',
        name: 'a.png',
        size: 128,
        mimeType: 'image/png',
      );
      final restored = PickedFile.fromJson(file.toJson());
      expect(restored, equals(file));
    });
  });

  group('pick result (FR-001 cancellation semantics)', () {
    test('a dismissed picker is an empty result, not an exception', () {
      expect(FilePickResult.canceled.isCanceled, isTrue);
      expect(FilePickResult().isCanceled, isTrue);
      expect(
        FilePickResult(files: [_file('a.png')]).isCanceled,
        isFalse,
      );
    });
  });

  group('in-memory adapter (FR-005)', () {
    test('every operation defaults to "user canceled"', () async {
      final adapter = InMemoryFilePickerAdapter();
      expect((await adapter.pickFiles(const FilePickOptions())).isCanceled,
          isTrue);
      expect(await adapter.saveFile(const FileSaveOptions()), isNull);
      expect(await adapter.pickDirectory(), isNull);
    });

    test('scripts a one-shot pick result, then cancels again', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(FilePickResult(files: [_file('a.png')]));
      expect(
        (await adapter.pickFiles(const FilePickOptions())).files.single.name,
        'a.png',
      );
      expect((await adapter.pickFiles(const FilePickOptions())).isCanceled,
          isTrue);
    });

    test('scripts one-shot save and directory outcomes', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextSavePath('/tmp/out.pdf')
        ..setNextDirectory('/tmp/docs');
      expect(await adapter.saveFile(const FileSaveOptions()), '/tmp/out.pdf');
      expect(await adapter.saveFile(const FileSaveOptions()), isNull);
      expect(await adapter.pickDirectory(), '/tmp/docs');
      expect(await adapter.pickDirectory(), isNull);
    });

    test('records the options each call received', () async {
      final options = const FilePickOptions(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        multiple: true,
      );
      final adapter = InMemoryFilePickerAdapter();
      await adapter.pickFiles(options);
      expect(adapter.lastPickOptions, same(options));
      expect(adapter.lastPickOptions!.type, FileType.custom);

      const save = FileSaveOptions(fileName: 'out.pdf');
      await adapter.saveFile(save);
      expect(adapter.lastSaveOptions, same(save));

      await adapter.pickDirectory(initialDirectory: '/tmp');
      expect(adapter.lastDirectoryInitial, '/tmp');
    });

    test('reset() clears scripts and recorded calls', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(FilePickResult(files: [_file('a.png')]));
      await adapter.pickFiles(const FilePickOptions());
      expect(adapter.lastPickOptions, isNotNull);
      adapter.reset();
      expect(adapter.lastPickOptions, isNull);
      expect(
        (await adapter.pickFiles(const FilePickOptions())).isCanceled,
        isTrue,
      );
    });
  });

  group('FilePickerService (FR-001/FR-004)', () {
    test('routes through the injected port', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(FilePickResult(files: [_file('a.png')]));
      final picker = FilePickerService(port: adapter);
      expect((await picker.pickFiles()).files.single.name, 'a.png');
    });

    test('defaults to the in-memory adapter', () async {
      final picker = FilePickerService();
      expect(picker.port, isA<InMemoryFilePickerAdapter>());
      expect((await picker.pickFiles()).isCanceled, isTrue);
    });

    test('custom type without extensions is a typed error', () {
      final picker = FilePickerService();
      expect(
        () => picker.pickFiles(const FilePickOptions(type: FileType.custom)),
        throwsA(
          isA<ZuraffaPlatformException>().having(
            (e) => e.code,
            'code',
            'missing_allowed_extensions',
          ),
        ),
      );
    });

    test('custom type with extensions passes through', () async {
      final adapter = InMemoryFilePickerAdapter();
      final picker = FilePickerService(port: adapter);
      await picker.pickFiles(
        const FilePickOptions(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        ),
      );
      expect(adapter.lastPickOptions!.allowedExtensions, ['pdf']);
    });
  });

  group('PickFilesUseCase (FR-003)', () {
    test('is a UseCase returning the port result', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(FilePickResult(files: [_file('a.png')]));
      final useCase = PickFilesUseCase(adapter);
      expect(useCase, isA<UseCase<FilePickResult, FilePickOptions>>());
      final result = await useCase.execute(
        const FilePickOptions(type: FileType.image),
        null,
      );
      expect(result.files.single.name, 'a.png');
      expect(adapter.lastPickOptions!.type, FileType.image);
    });

    test('call() wraps the port result in a Result', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(FilePickResult(files: [_file('a.png')]));
      final result = await PickFilesUseCase(adapter).call(
        const FilePickOptions(),
      );
      result.fold(
        (picked) => expect(picked.files.single.name, 'a.png'),
        (failure) => fail('unexpected failure: $failure'),
      );
    });

    test('honors a cancelled token', () {
      final token = CancelToken()..cancel('user left');
      final useCase = PickFilesUseCase(InMemoryFilePickerAdapter());
      expect(
        () => useCase.execute(const FilePickOptions(), token),
        throwsA(isA<CancelledException>()),
      );
    });
  });

  group('DI wiring (FR-007)', () {
    tearDown(() {
      // Restore the pure-Dart default: a factory that reproduces the
      // built-in fallback.
      setPlatformFilePickerPortFactory(InMemoryFilePickerAdapter.new);
    });

    test('registers port, service and use case', () {
      final getIt = GetIt.asNewInstance();
      registerFilePickerDependencies(getIt);
      expect(getIt<FilePickerPort>(), isA<InMemoryFilePickerAdapter>());
      expect(getIt<FilePickerService>().port, same(getIt<FilePickerPort>()));
      expect(getIt<PickFilesUseCase>(), isA<PickFilesUseCase>());
    });

    test('an injected port wins over every default', () {
      final getIt = GetIt.asNewInstance();
      final adapter = InMemoryFilePickerAdapter();
      registerFilePickerDependencies(getIt, port: adapter);
      expect(getIt<FilePickerPort>(), same(adapter));
    });

    test('the platform factory supplies the port', () {
      final adapter = InMemoryFilePickerAdapter();
      setPlatformFilePickerPortFactory(() => adapter);
      final getIt = GetIt.asNewInstance();
      registerFilePickerDependencies(getIt);
      expect(getIt<FilePickerPort>(), same(adapter));
    });
  });
}
