import 'package:zuraffa/zuraffa.dart';

import 'data/file_picker/in_memory_file_picker_adapter.dart';
import 'domain/entities/enums/file_type.dart';
import 'domain/entities/file_pick_options/file_pick_options.dart';
import 'domain/entities/file_pick_result/file_pick_result.dart';
import 'domain/entities/file_save_options/file_save_options.dart';
import 'domain/file_picker_port.dart';
import 'domain/usecases/pick_files_usecase.dart';

export 'domain/file_picker_port.dart';

/// The app-facing file picker service: the port plus input validation.
///
/// ```dart
/// final picker = FilePickerService(port: InMemoryFilePickerAdapter());
/// final result = await picker.pickFiles(FilePickOptions(type: FileType.image));
/// ```
class FilePickerService {
  /// The platform adapter (or the in-memory default in tests).
  final FilePickerPort port;

  FilePickerService({FilePickerPort? port})
    : port = port ?? InMemoryFilePickerAdapter();

  /// Opens the file picker for [options].
  ///
  /// A [FileType.custom] without [FilePickOptions.allowedExtensions] is
  /// a typed error — a typo in your own picker wiring should fail fast,
  /// not open an unfiltered dialog.
  Future<FilePickResult> pickFiles([
    FilePickOptions options = const FilePickOptions(),
  ]) {
    if (options.type == FileType.custom && options.allowedExtensions.isEmpty) {
      throw ZuraffaPlatformException(
        code: 'missing_allowed_extensions',
        message:
            'FileType.custom requires FilePickOptions.allowedExtensions, '
            'e.g. FilePickOptions(type: FileType.custom, allowedExtensions: ["pdf"]).',
      );
    }
    return port.pickFiles(options);
  }

  /// Opens a save flow; returns the saved document path or `null` when
  /// the user canceled.
  Future<String?> saveFile([
    FileSaveOptions options = const FileSaveOptions(),
  ]) => port.saveFile(options);

  /// Opens a directory picker; returns the path or `null` when the user
  /// canceled.
  Future<String?> pickDirectory({String? initialDirectory}) =>
      port.pickDirectory(initialDirectory: initialDirectory);
}

/// Optional factory installed by a federated platform package so apps get
/// the real OS picker without wiring the adapter by hand.
///
/// `zuraffa_file_picker_android` / `_ios` / `_macos` call
/// [setPlatformFilePickerPortFactory] from their `registerWith()` (which
/// Flutter runs when the app starts). Until one does, the package stays
/// pure Dart and defaults to [InMemoryFilePickerAdapter] — so it tests
/// without a platform (FR-005) and consumers can still inject a custom
/// [FilePickerPort].
FilePickerPort? Function()? _platformPortFactory;

/// Called by a platform package at registration time to supply the real
/// [FilePickerPort] (bridged onto its native [ZuraffaFilePickerPlatform]).
void setPlatformFilePickerPortFactory(FilePickerPort Function() factory) {
  _platformPortFactory = factory;
}

/// The default [FilePickerPort] when the caller injects none: the platform
/// package's real adapter if one registered, otherwise the in-memory
/// default.
FilePickerPort _defaultFilePickerPort() =>
    _platformPortFactory?.call() ?? InMemoryFilePickerAdapter();

/// Registers the file picker stack onto [getIt] (FR-007).
///
/// ```dart
/// final getIt = GetIt.instance;
/// registerFilePickerDependencies(getIt);
/// final picker = getIt<FilePickerService>();
/// ```
void registerFilePickerDependencies(GetIt getIt, {FilePickerPort? port}) {
  getIt
    ..registerLazySingleton<FilePickerPort>(
      () => port ?? _defaultFilePickerPort(),
    )
    ..registerLazySingleton<FilePickerService>(
      () => FilePickerService(port: getIt<FilePickerPort>()),
    )
    ..registerLazySingleton<PickFilesUseCase>(
      () => PickFilesUseCase(getIt<FilePickerPort>()),
    );
}
