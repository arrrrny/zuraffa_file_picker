/// zuraffa_file_picker — typed file picking for the Zuraffa ecosystem.
///
/// A [FilePickerPort] (pickFiles / saveFile / pickDirectory) over typed
/// entities ([PickedFile], [FilePickResult]) and an in-memory default
/// adapter so picker flows are testable in pure Dart. Platform adapters
/// (zuraffa_file_picker_android/ios/macos) implement the port as
/// federated siblings: add one to your app and the real OS picker is
/// wired automatically at startup.
///
/// Built on the Zuraffa framework (issue #674, EPIC #214): picked files
/// are Zuraffa entities (FR-001/FR-002) and picking flows through a
/// Zuraffa use case (FR-003) resolvable from GetIt (FR-007).
///
/// ```dart
/// final picker = FilePickerService();
/// final result = await picker.pickFiles(FilePickOptions(type: FileType.image));
/// if (!result.isCanceled) {
///   print(result.files.first.path);
/// }
/// ```
library;

export 'src/domain/entities/enums/file_type.dart';
export 'src/domain/entities/enums/picker_host.dart';
export 'src/domain/entities/enums/picker_source.dart';
export 'src/domain/entities/file_pick_options/file_pick_options.dart';
export 'src/domain/entities/file_pick_result/file_pick_result.dart';
export 'src/domain/entities/file_save_options/file_save_options.dart';
export 'src/domain/entities/picked_file/picked_file.dart';
export 'src/domain/file_picker_port.dart';
export 'src/domain/picker_source_router.dart';
export 'src/domain/usecases/pick_files_usecase.dart';
export 'src/data/file_picker/in_memory_file_picker_adapter.dart';
export 'src/file_picker_service.dart';
