import '../picked_file/picked_file.dart';

/// The outcome of a [FilePickerPort.pickFiles] call.
///
/// A dismissed picker is an **empty result, not an exception** (FR-001):
/// [isCanceled] lets callers handle "the user changed their mind" as a
/// plain branch instead of a try/catch.
class FilePickResult {
  const FilePickResult({this.files = const []});

  /// The result of a dismissed picker.
  static const FilePickResult canceled = FilePickResult();

  /// The picked files; empty when the user canceled.
  final List<PickedFile> files;

  /// Whether the user dismissed the picker without picking anything.
  bool get isCanceled => files.isEmpty;
}
