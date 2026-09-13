import 'package:flutter/material.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

/// The simulator's producer-side buttons: the [InMemoryFilePickerAdapter]
/// test seams exposed in the UI, so every port outcome — files, paths,
/// cancellations — is demonstrable without OS integration.
class SimulatorSeamsCard extends StatelessWidget {
  const SimulatorSeamsCard({
    super.key,
    required this.adapter,
    required this.onChanged,
  });

  final InMemoryFilePickerAdapter adapter;

  /// Called after a seam mutates the adapter so the app re-renders.
  final VoidCallback onChanged;

  void _stageFiles(int count) {
    adapter.setNextPickResult(
      FilePickResult(
        files: [
          for (var i = 1; i <= count; i++)
            PickedFile(
              path: '/simulated/picked-file-$i.png',
              name: 'picked-file-$i.png',
              size: 1024 * i,
              mimeType: 'image/png',
            ),
        ],
      ),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simulator seams', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'InMemoryFilePickerAdapter scripting — what the next operation '
              'resolves with (one-shot).',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  key: const Key('stage-file'),
                  onPressed: () => _stageFiles(1),
                  child: const Text('Stage 1 file'),
                ),
                OutlinedButton(
                  key: const Key('stage-files'),
                  onPressed: () => _stageFiles(3),
                  child: const Text('Stage 3 files'),
                ),
                OutlinedButton(
                  key: const Key('stage-save-path'),
                  onPressed: () {
                    adapter.setNextSavePath('/simulated/report.txt');
                    onChanged();
                  },
                  child: const Text('Stage save path'),
                ),
                OutlinedButton(
                  key: const Key('stage-directory'),
                  onPressed: () {
                    adapter.setNextDirectory('/simulated/documents');
                    onChanged();
                  },
                  child: const Text('Stage directory'),
                ),
                OutlinedButton(
                  key: const Key('stage-cancel'),
                  onPressed: () {
                    // The adapter's default: every operation resolves to
                    // "the user canceled".
                    onChanged();
                  },
                  child: const Text('Stage cancel (default)'),
                ),
              ],
            ),
            if (adapter.lastPickOptions != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last recorded options: ${adapter.lastPickOptions}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
