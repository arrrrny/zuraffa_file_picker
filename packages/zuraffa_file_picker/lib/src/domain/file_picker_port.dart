import 'entities/file_pick_options/file_pick_options.dart';
import 'entities/file_pick_result/file_pick_result.dart';
import 'entities/file_save_options/file_save_options.dart';

/// The technology-agnostic file picking contract (FR-001).
///
/// Consumers program against this port; platform adapters
/// (zuraffa_file_picker_android/ios/macos) implement it. The default
/// [InMemoryFilePickerAdapter] is a pure-Dart scripted adapter so the
/// whole package — and every app's picker flow — tests without a
/// platform.
///
/// Cancellation is never an exception: a dismissed picker resolves to an
/// empty [FilePickResult] (`isCanceled`) or a `null` path.
abstract class FilePickerPort {
  /// Opens the system file picker for [options].
  ///
  /// Returns the picked files, or an empty [FilePickResult]
  /// (`isCanceled == true`) when the user dismissed the picker.
  Future<FilePickResult> pickFiles(FilePickOptions options);

  /// Opens a save dialog (or a create-document flow) for [options].
  ///
  /// Returns the path of the saved document — a readable snapshot of
  /// what was written — or `null` when the user canceled.
  Future<String?> saveFile(FileSaveOptions options);

  /// Opens a directory picker.
  ///
  /// Returns the selected directory path, or `null` when the user
  /// canceled.
  Future<String?> pickDirectory({String? initialDirectory});
}
