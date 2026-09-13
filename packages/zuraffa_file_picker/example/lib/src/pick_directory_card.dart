import 'package:flutter/material.dart';

import 'picker_controller.dart';
import 'result_tiles.dart';

/// The `pickDirectory` panel: choose a folder, get a filesystem path.
class PickDirectoryCard extends StatefulWidget {
  const PickDirectoryCard({super.key, required this.controller});

  final PickerController controller;

  @override
  State<PickDirectoryCard> createState() => _PickDirectoryCardState();
}

class _PickDirectoryCardState extends State<PickDirectoryCard> {
  final _initialDirectory = TextEditingController();

  @override
  void dispose() {
    _initialDirectory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = widget.controller.lastDirectory;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('pickDirectory', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'FilePickerPort.pickDirectory({initialDirectory}) → String? '
              '(null = canceled)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _initialDirectory,
              decoration: const InputDecoration(
                labelText: 'Initial directory (optional)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('pick-directory-run'),
              onPressed: () => widget.controller.pickDirectory(
                initialDirectory: _initialDirectory.text.isEmpty
                    ? null
                    : _initialDirectory.text,
              ),
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Pick directory'),
            ),
            if (path != null) ...[
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                leading: const Icon(Icons.folder_outlined, size: 18),
                title: Text(
                  path,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (widget.controller.lastDirectoryCanceled)
              const CanceledTile(operation: 'pickDirectory'),
          ],
        ),
      ),
    );
  }
}
