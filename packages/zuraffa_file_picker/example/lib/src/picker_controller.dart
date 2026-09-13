import 'package:flutter/foundation.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

/// Which adapter backs the service the UI drives.
enum PickerMode { live, simulator }

/// One recorded operation outcome in the flow log.
@immutable
class FlowEntry {
  const FlowEntry(this.text, {required this.isError});

  final String text;
  final bool isError;
}

/// The app's state holder: routes every operation through the active
/// [FilePickerService], records the outcome in the flow log, and surfaces
/// errors verbatim instead of swallowing them.
class PickerController extends ChangeNotifier {
  PickerController({
    required this.live,
    required this.simulatorAdapter,
  }) : simulator = FilePickerService(port: simulatorAdapter);

  /// The GetIt-registered stack (real method-channel adapters).
  final FilePickerService live;

  /// The scripted pure-Dart adapter.
  final InMemoryFilePickerAdapter simulatorAdapter;

  /// A service bound to the scripted adapter.
  final FilePickerService simulator;

  PickerMode mode = PickerMode.live;

  FilePickerService get service => mode == PickerMode.live ? live : simulator;

  /// Latest outcomes, newest first.
  final List<FlowEntry> log = [];

  /// The verbatim error from the last failed operation, if any.
  String? error;

  /// The last pick result (rendered by the pick panel).
  FilePickResult? lastPickResult;

  /// The last saved path (rendered by the save panel).
  String? lastSavePath;

  /// Whether the last [saveFile] was dismissed.
  bool lastSaveCanceled = false;

  /// The last directory (rendered by the directory panel).
  String? lastDirectory;

  /// Whether the last [pickDirectory] was dismissed.
  bool lastDirectoryCanceled = false;

  void setMode(PickerMode newMode) {
    mode = newMode;
    notifyListeners();
  }

  void _record(String text, {bool isError = false}) {
    log.insert(0, FlowEntry(text, isError: isError));
    if (log.length > 50) log.removeLast();
  }

  Future<void> pickFiles(FilePickOptions options) async {
    try {
      final result = await service.pickFiles(options);
      lastPickResult = result;
      error = null;
      _record(
        result.isCanceled
            ? 'pickFiles → canceled'
            : 'pickFiles → ${result.files.length} file(s): '
                '${result.files.map((f) => f.name).join(", ")}',
      );
    } catch (e) {
      error = e.toString();
      _record('pickFiles → ${e.toString()}', isError: true);
    }
    notifyListeners();
  }

  Future<void> saveFile(FileSaveOptions options) async {
    try {
      final path = await service.saveFile(options);
      lastSavePath = path;
      lastSaveCanceled = path == null;
      error = null;
      _record(path == null ? 'saveFile → canceled' : 'saveFile → $path');
    } catch (e) {
      error = e.toString();
      _record('saveFile → ${e.toString()}', isError: true);
    }
    notifyListeners();
  }

  Future<void> pickDirectory({String? initialDirectory}) async {
    try {
      final path = await service.pickDirectory(initialDirectory: initialDirectory);
      lastDirectory = path;
      lastDirectoryCanceled = path == null;
      error = null;
      _record(
        path == null ? 'pickDirectory → canceled' : 'pickDirectory → $path',
      );
    } catch (e) {
      error = e.toString();
      _record('pickDirectory → ${e.toString()}', isError: true);
    }
    notifyListeners();
  }

  /// Dismisses the error banner.
  void clearError() {
    error = null;
    notifyListeners();
  }
}
