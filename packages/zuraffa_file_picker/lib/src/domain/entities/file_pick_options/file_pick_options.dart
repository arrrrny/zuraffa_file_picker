import '../enums/file_type.dart';
import '../enums/picker_source.dart';

/// Options for [FilePickerPort.pickFiles] (FR-004).
class FilePickOptions {
  const FilePickOptions({
    this.type = FileType.any,
    this.allowedExtensions = const [],
    this.multiple = false,
    this.initialDirectory,
    this.source = PickerSource.auto,
  });

  /// The picker filter. [FileType.custom] requires
  /// [allowedExtensions] to be non-empty.
  final FileType type;

  /// Extensions for [FileType.custom], without the dot
  /// (`['pdf', 'png']`). Honored exactly by the document source; the
  /// photo source filters by *kind* (images / videos) and treats them
  /// as advisory, like `file_picker`'s `FileType.media`.
  final List<String> allowedExtensions;

  /// Whether the user may pick more than one file.
  final bool multiple;

  /// Where the dialog should open, when the platform supports it.
  final String? initialDirectory;

  /// Which native picker source serves the request (spec 002).
  ///
  /// [PickerSource.auto] — the default — resolves per platform through
  /// [PickerSourceRouter.resolve]: on iOS the `media`/`image`/`video`
  /// types open the photo library (PHPicker) and everything else opens
  /// the document picker, matching `file_picker`'s routing.
  final PickerSource source;

  @override
  String toString() =>
      'FilePickOptions(type: $type, allowedExtensions: $allowedExtensions, '
      'multiple: $multiple, initialDirectory: $initialDirectory, '
      'source: $source)';
}
