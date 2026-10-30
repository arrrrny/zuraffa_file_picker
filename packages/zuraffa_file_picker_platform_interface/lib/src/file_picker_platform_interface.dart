import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The wire vocabulary exchanged over the MethodChannel: method names,
/// request keys and file-descriptor keys (stable strings — the typed
/// options/results live in the app-facing package).
abstract final class FilePickerWire {
  // Method names.
  static const pickFiles = 'pickFiles';
  static const saveFile = 'saveFile';
  static const pickDirectory = 'pickDirectory';

  // Request keys.
  static const type = 'type';
  static const allowedExtensions = 'allowedExtensions';
  static const multiple = 'multiple';
  static const initialDirectory = 'initialDirectory';
  static const source = 'source';
  static const fileName = 'fileName';
  static const bytes = 'bytes';

  // File descriptor keys.
  static const path = 'path';
  static const name = 'name';
  static const size = 'size';
  static const mimeType = 'mimeType';
}

/// The native contract every zuraffa_file_picker platform package
/// implements: pick files, save a file, pick a directory.
///
/// The channel protocol (method → arguments → result):
/// - `pickFiles` → `{type, allowedExtensions, multiple, source,
///   initialDirectory?}` → `List<Map>` of file descriptors
///   (`path`/`name`/`size`/`mimeType`), or `null` when the user
///   dismissed the picker. `source` is the **resolved** picker source
///   (`document` / `photoLibrary`) — the Dart side owns the routing
///   ([PickerSourceRouter]) so native sides only switch on an explicit
///   value and default to `document` when the key is absent.
/// - `saveFile` → `{fileName?, initialDirectory?, bytes?}` →
///   `String?` saved path, or `null` when dismissed.
/// - `pickDirectory` → `String?` (initial directory) → `String?`
///   directory path, or `null` when dismissed.
abstract class ZuraffaFilePickerPlatform extends PlatformInterface {
  /// Constructs a platform interface.
  ZuraffaFilePickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZuraffaFilePickerPlatform _instance =
      DefaultZuraffaFilePickerPlatform();

  /// The default instance (overridden by platform packages at
  /// registration time via [instance = ...]).
  static ZuraffaFilePickerPlatform get instance => _instance;

  /// Platform packages set this to their native implementation.
  static set instance(ZuraffaFilePickerPlatform value) {
    PlatformInterface.verifyToken(value, _token);
    _instance = value;
  }

  /// Opens the file picker; returns one descriptor map per picked file,
  /// or `null` when the user dismissed the picker.
  Future<List<Map<Object?, Object?>>?> pickFiles(
    Map<Object?, Object?> options,
  );

  /// Opens the save flow; returns the saved path, or `null` when the
  /// user dismissed it.
  Future<String?> saveFile(Map<Object?, Object?> options);

  /// Opens the directory picker; returns the path, or `null` when the
  /// user dismissed it.
  Future<String?> pickDirectory(String? initialDirectory);
}

/// The fallback used when no platform package registered — every
/// operation reports "dismissed". This makes the interface safe to
/// depend on before a platform package loads (tests, pure-Dart hosts).
class DefaultZuraffaFilePickerPlatform extends ZuraffaFilePickerPlatform {
  @override
  Future<List<Map<Object?, Object?>>?> pickFiles(
    Map<Object?, Object?> options,
  ) async => null;

  @override
  Future<String?> saveFile(Map<Object?, Object?> options) async => null;

  @override
  Future<String?> pickDirectory(String? initialDirectory) async => null;
}
