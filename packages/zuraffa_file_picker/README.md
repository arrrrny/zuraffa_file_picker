# zuraffa_file_picker

Typed file picking for the [Zuraffa](https://pub.dev/packages/zuraffa)
ecosystem: a pure-Dart `FilePickerPort` (pick files / save file / pick
directory) with an in-memory default adapter, so picker flows test
without a platform. Platform adapters
(`zuraffa_file_picker_android/ios/macos`) implement the port as
federated siblings — add one and the real OS picker is wired
automatically at startup.

## Usage

```dart
final picker = FilePickerService();

// Pick files (empty result = user canceled).
final result = await picker.pickFiles(
  FilePickOptions(type: FileType.image, multiple: true),
);
if (!result.isCanceled) {
  for (final file in result.files) {
    print('${file.name} (${file.size} bytes) at ${file.path}');
  }
}

// Save a file (null = user canceled).
final path = await picker.saveFile(
  FileSaveOptions(fileName: 'report.pdf', bytes: pdfBytes),
);

// Pick a directory (null = user canceled).
final dir = await picker.pickDirectory();
```

## DI

```dart
final getIt = GetIt.instance;
registerFilePickerDependencies(getIt);
final picker = getIt<FilePickerService>();
```

## Testing

The default `InMemoryFilePickerAdapter` scripts outcomes:

```dart
final adapter = InMemoryFilePickerAdapter()
  ..setNextPickResult(FilePickResult(files: [PickedFile(path: '/tmp/a.png', name: 'a.png', size: 12)]));
final picker = FilePickerService(port: adapter);
```

This package is the foundation layer; see
[`zuraffa_file_picker_platform_interface`](../zuraffa_file_picker_platform_interface/)
for the channel protocol and the platform packages for the native
implementations.
