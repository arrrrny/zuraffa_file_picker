import 'package:flutter/material.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

import 'picker_controller.dart';
import 'result_tiles.dart';

/// The `pickFiles` panel: the full [FilePickOptions] surface plus the
/// typed [PickedFile] results — the API tour for the plugin's primary
/// operation.
class PickFilesCard extends StatefulWidget {
  const PickFilesCard({
    super.key,
    required this.controller,
    required this.simulatorAdapter,
  });

  final PickerController controller;
  final InMemoryFilePickerAdapter simulatorAdapter;

  @override
  State<PickFilesCard> createState() => _PickFilesCardState();
}

class _PickFilesCardState extends State<PickFilesCard> {
  FileType _type = FileType.any;
  final Set<String> _extensions = {};
  bool _multiple = false;
  final _initialDirectory = TextEditingController();

  static const _offeredExtensions = ['pdf', 'png', 'txt', 'csv', 'zip'];

  @override
  void dispose() {
    _initialDirectory.dispose();
    super.dispose();
  }

  FilePickOptions get _options => FilePickOptions(
    type: _type,
    allowedExtensions: _extensions.toList(growable: false),
    multiple: _multiple,
    initialDirectory: _initialDirectory.text.isEmpty
        ? null
        : _initialDirectory.text,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.controller.lastPickResult;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('pickFiles', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'FilePickerPort.pickFiles(FilePickOptions) → FilePickResult '
              '(empty result = canceled)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Type:'),
                DropdownButton<FileType>(
                  value: _type,
                  items: [
                    for (final type in FileType.values)
                      DropdownMenuItem(value: type, child: Text(type.name)),
                  ],
                  onChanged: (type) => setState(() => _type = type!),
                ),
              ],
            ),
            if (_type == FileType.custom) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final extension in _offeredExtensions)
                    FilterChip(
                      label: Text('.$extension'),
                      selected: _extensions.contains(extension),
                      onSelected: (selected) => setState(() {
                        selected
                            ? _extensions.add(extension)
                            : _extensions.remove(extension);
                      }),
                    ),
                ],
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Multiple'),
              value: _multiple,
              onChanged: (value) => setState(() => _multiple = value),
            ),
            TextField(
              controller: _initialDirectory,
              decoration: const InputDecoration(
                labelText: 'Initial directory (optional)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('pick-files-run'),
              onPressed: () => widget.controller.pickFiles(_options),
              icon: const Icon(Icons.file_open_outlined),
              label: const Text('Pick files'),
            ),
            if (result != null) ...[
              const SizedBox(height: 8),
              if (result.isCanceled)
                const CanceledTile(operation: 'pickFiles')
              else
                ...[for (final file in result.files) PickedFileTile(file: file)],
            ],
          ],
        ),
      ),
    );
  }
}
