import 'package:flutter/material.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

import 'flow_log_view.dart';
import 'pick_directory_card.dart';
import 'pick_files_card.dart';
import 'picker_controller.dart';
import 'save_file_card.dart';
import 'simulator_seams_card.dart';

/// The home screen: a live/simulator mode switch, one panel per port
/// operation, the verbatim error banner, and the flow log.
class FilePickerHome extends StatefulWidget {
  const FilePickerHome({super.key, this.liveService, this.simulatorAdapter});

  final FilePickerService? liveService;
  final InMemoryFilePickerAdapter? simulatorAdapter;

  @override
  FilePickerHomeState createState() => FilePickerHomeState();
}

/// Exposed so tests can assert which service backs the active mode.
class FilePickerHomeState extends State<FilePickerHome> {
  late final PickerController _controller;

  /// The app's state holder.
  PickerController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = PickerController(
      live: widget.liveService ?? FilePickerService(),
      simulatorAdapter: widget.simulatorAdapter ?? InMemoryFilePickerAdapter(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('zuraffa_file_picker'),
        actions: [
          SegmentedButton<PickerMode>(
            key: const Key('mode-switch'),
            segments: const [
              ButtonSegment(
                value: PickerMode.live,
                label: Text('Live OS'),
                icon: Icon(Icons.devices),
              ),
              ButtonSegment(
                value: PickerMode.simulator,
                label: Text('Simulator'),
                icon: Icon(Icons.science_outlined),
              ),
            ],
            selected: {controller.mode},
            onSelectionChanged: (selection) =>
                setState(() => controller.setMode(selection.first)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return ListView(
            children: [
              if (controller.error != null)
                _ErrorBanner(
                  message: controller.error!,
                  onDismiss: controller.clearError,
                ),
              if (controller.mode == PickerMode.simulator)
                SimulatorSeamsCard(
                  adapter: controller.simulatorAdapter,
                  onChanged: () {},
                ),
              PickFilesCard(
                controller: controller,
                simulatorAdapter: controller.simulatorAdapter,
              ),
              SaveFileCard(controller: controller),
              PickDirectoryCard(controller: controller),
              Card(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'Flow log',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FlowLogView(entries: controller.log),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Errors surface verbatim — the `channel-error` class proves a missing
/// native half, and the typed `missing_allowed_extensions` failure comes
/// straight from the service.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: theme.colorScheme.error),
        title: Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
        trailing: IconButton(
          key: const Key('error-dismiss'),
          icon: const Icon(Icons.close),
          onPressed: onDismiss,
        ),
      ),
    );
  }
}
