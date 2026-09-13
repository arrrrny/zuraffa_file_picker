import '../../domain/entities/file_pick_options/file_pick_options.dart';
import '../../domain/entities/file_pick_result/file_pick_result.dart';
import '../../domain/entities/file_save_options/file_save_options.dart';
import '../../domain/file_picker_port.dart';

/// Pure-Dart default adapter (FR-005): a scripted file picker. Without a
/// script every operation reports "the user canceled", so production code
/// paths can run headless; tests script the outcomes a real picker would
/// produce and can assert on the options the caller sent.
///
/// ```dart
/// final adapter = InMemoryFilePickerAdapter()
///   ..setNextPickResult(FilePickResult(files: [
///     PickedFile(path: '/tmp/a.png', name: 'a.png', size: 128),
///   ]));
/// final result = await adapter.pickFiles(const FilePickOptions());
/// ```
class InMemoryFilePickerAdapter implements FilePickerPort {
  FilePickResult? _nextPickResult;
  String? _nextSavePath;
  String? _nextDirectory;

  /// The options the last [pickFiles] call received.
  FilePickOptions? lastPickOptions;

  /// The options the last [saveFile] call received.
  FileSaveOptions? lastSaveOptions;

  /// The initial directory the last [pickDirectory] call received.
  String? lastDirectoryInitial;

  /// Scripts the outcome of the next [pickFiles] call (one-shot; further
  /// calls return the canceled result until scripted again).
  void setNextPickResult(FilePickResult result) => _nextPickResult = result;

  /// Scripts the outcome of the next [saveFile] call (one-shot; further
  /// calls return `null` — canceled — until scripted again).
  void setNextSavePath(String? path) => _nextSavePath = path;

  /// Scripts the outcome of the next [pickDirectory] call (one-shot;
  /// further calls return `null` — canceled — until scripted again).
  void setNextDirectory(String? path) => _nextDirectory = path;

  /// Clears every script and recorded call.
  void reset() {
    _nextPickResult = null;
    _nextSavePath = null;
    _nextDirectory = null;
    lastPickOptions = null;
    lastSaveOptions = null;
    lastDirectoryInitial = null;
  }

  @override
  Future<FilePickResult> pickFiles(FilePickOptions options) async {
    lastPickOptions = options;
    try {
      return _nextPickResult ?? FilePickResult.canceled;
    } finally {
      _nextPickResult = null;
    }
  }

  @override
  Future<String?> saveFile(FileSaveOptions options) async {
    lastSaveOptions = options;
    try {
      return _nextSavePath;
    } finally {
      _nextSavePath = null;
    }
  }

  @override
  Future<String?> pickDirectory({String? initialDirectory}) async {
    lastDirectoryInitial = initialDirectory;
    try {
      return _nextDirectory;
    } finally {
      _nextDirectory = null;
    }
  }
}
