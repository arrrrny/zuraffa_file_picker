import '../enums/file_type.dart';

/// Options for [FilePickerPort.pickFiles] (FR-004).
class FilePickOptions {
  const FilePickOptions({
    this.type = FileType.any,
    this.allowedExtensions = const [],
    this.multiple = false,
    this.initialDirectory,
  });

  /// The picker filter. [FileType.custom] requires
  /// [allowedExtensions] to be non-empty.
  final FileType type;

  /// Extensions for [FileType.custom], without the dot
  /// (`['pdf', 'png']`). Ignored for the built-in types.
  final List<String> allowedExtensions;

  /// Whether the user may pick more than one file.
  final bool multiple;

  /// Where the dialog should open, when the platform supports it.
  final String? initialDirectory;

  @override
  String toString() =>
      'FilePickOptions(type: $type, allowedExtensions: $allowedExtensions, '
      'multiple: $multiple, initialDirectory: $initialDirectory)';
}
