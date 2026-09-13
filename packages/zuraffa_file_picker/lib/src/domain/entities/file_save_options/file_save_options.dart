import 'dart:typed_data';

/// Options for [FilePickerPort.saveFile].
class FileSaveOptions {
  const FileSaveOptions({this.fileName, this.initialDirectory, this.bytes});

  /// Suggested file name (the user can edit it in the save dialog).
  final String? fileName;

  /// Where the dialog should open, when the platform supports it.
  final String? initialDirectory;

  /// Content to write into the created document. When omitted an empty
  /// document is created and its (readable snapshot) path is returned.
  final Uint8List? bytes;

  @override
  String toString() =>
      'FileSaveOptions(fileName: $fileName, initialDirectory: '
      '$initialDirectory, bytes: ${bytes?.length ?? 0} bytes)';
}
