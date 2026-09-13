import 'package:flutter/material.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

import 'src/file_picker_home.dart';

/// Host app for the zuraffa_file_picker federated plugin.
///
/// It wires the real (method-channel) [FilePickerPort] onto GetIt via
/// [registerFilePickerDependencies] — the federated platform adapters
/// (`zuraffa_file_picker_android` / `_ios` / `_macos`) register their port
/// factory when Flutter starts the app, so the live mode exercises the
/// actual OS pickers. The simulator mode drives the package's pure-Dart
/// [InMemoryFilePickerAdapter] so every outcome — including cancellations
/// and files a real dialog would never hand you — can be staged and
/// observed on demand.
void main() {
  registerFilePickerDependencies(GetIt.instance);
  runApp(FilePickerApp(liveService: GetIt.instance<FilePickerService>()));
}

/// The example app root.
///
/// Both modes share the public [FilePickerService] API; only the adapter
/// behind the port differs (in-memory simulator vs. the GetIt-registered
/// live stack).
class FilePickerApp extends StatelessWidget {
  const FilePickerApp({super.key, this.liveService, this.simulatorAdapter});

  /// Service behind the live mode; defaults to the instance GetIt
  /// registered.
  final FilePickerService? liveService;

  /// The scripted adapter behind the simulator mode.
  final InMemoryFilePickerAdapter? simulatorAdapter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zuraffa_file_picker',
      theme: ThemeData(useMaterial3: true),
      home: FilePickerHome(
        liveService: liveService,
        simulatorAdapter: simulatorAdapter,
      ),
    );
  }
}
