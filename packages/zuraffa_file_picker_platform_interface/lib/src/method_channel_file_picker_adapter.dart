import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

import 'file_picker_platform_interface.dart';

/// Bridges the [ZuraffaFilePickerPlatform] native implementation onto
/// the package's pure-Dart [FilePickerPort], so apps register the real
/// platform stack with the same DI seam as the in-memory tests:
///
/// ```dart
/// registerFilePickerDependencies(
///   getIt,
///   port: MethodChannelFilePickerAdapter(),
/// );
/// ```
///
/// A dismissed picker (`null` from the platform) becomes an empty
/// [FilePickResult] — cancellation stays a plain value end to end. A
/// missing or malformed descriptor field degrades to a safe default
/// (size `0`, mime `null`) instead of crashing the flow.
class MethodChannelFilePickerAdapter implements FilePickerPort {
  /// The platform instance backing this adapter (defaults to
  /// [ZuraffaFilePickerPlatform.instance]).
  final ZuraffaFilePickerPlatform platform;

  MethodChannelFilePickerAdapter({ZuraffaFilePickerPlatform? platform})
    : platform = platform ?? ZuraffaFilePickerPlatform.instance;

  @override
  Future<FilePickResult> pickFiles(FilePickOptions options) async {
    final descriptors = await platform.pickFiles({
      FilePickerWire.type: options.type.name,
      FilePickerWire.allowedExtensions: List<String>.of(
        options.allowedExtensions,
      ),
      FilePickerWire.multiple: options.multiple,
      if (options.initialDirectory != null)
        FilePickerWire.initialDirectory: options.initialDirectory,
    });
    if (descriptors == null) return FilePickResult.canceled;
    return FilePickResult(
      files: [for (final descriptor in descriptors) _toPickedFile(descriptor)],
    );
  }

  @override
  Future<String?> saveFile(FileSaveOptions options) => platform.saveFile({
    if (options.fileName != null) FilePickerWire.fileName: options.fileName,
    if (options.initialDirectory != null)
      FilePickerWire.initialDirectory: options.initialDirectory,
    if (options.bytes != null) FilePickerWire.bytes: options.bytes,
  });

  @override
  Future<String?> pickDirectory({String? initialDirectory}) =>
      platform.pickDirectory(initialDirectory);

  static PickedFile _toPickedFile(Map<Object?, Object?> descriptor) =>
      PickedFile(
        path: '${descriptor[FilePickerWire.path] ?? ''}',
        name: '${descriptor[FilePickerWire.name] ?? ''}',
        size: _toInt(descriptor[FilePickerWire.size]),
        mimeType: descriptor[FilePickerWire.mimeType]?.toString(),
      );

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
