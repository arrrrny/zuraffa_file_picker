import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

import 'picker_controller.dart';
import 'result_tiles.dart';

/// The `saveFile` panel: a suggested name, optional content bytes, and the
/// readable snapshot path the port hands back.
class SaveFileCard extends StatefulWidget {
  const SaveFileCard({super.key, required this.controller});

  final PickerController controller;

  @override
  State<SaveFileCard> createState() => _SaveFileCardState();
}

class _SaveFileCardState extends State<SaveFileCard> {
  final _fileName = TextEditingController(text: 'zuraffa-report.txt');
  final _initialDirectory = TextEditingController();
  bool _includeBytes = true;

  @override
  void dispose() {
    _fileName.dispose();
    _initialDirectory.dispose();
    super.dispose();
  }

  FileSaveOptions get _options => FileSaveOptions(
    fileName: _fileName.text.isEmpty ? null : _fileName.text,
    initialDirectory: _initialDirectory.text.isEmpty
        ? null
        : _initialDirectory.text,
    bytes: _includeBytes
        ? Uint8List.fromList(
            utf8.encode('zuraffa_file_picker example — ${DateTime.now()}\n'),
          )
        : null,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = widget.controller.lastSavePath;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('saveFile', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'FilePickerPort.saveFile(FileSaveOptions) → String? '
              '(null = canceled; the path is a readable snapshot)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fileName,
              decoration: const InputDecoration(
                labelText: 'File name',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _initialDirectory,
              decoration: const InputDecoration(
                labelText: 'Initial directory (optional)',
                isDense: true,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Write sample bytes'),
              subtitle: const Text('FileSaveOptions.bytes'),
              value: _includeBytes,
              onChanged: (value) => setState(() => _includeBytes = value),
            ),
            const SizedBox(height: 4),
            FilledButton.icon(
              key: const Key('save-file-run'),
              onPressed: () => widget.controller.saveFile(_options),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save file'),
            ),
            if (path != null) ...[
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline, size: 18),
                title: Text(
                  path,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (widget.controller.lastSaveCanceled)
              const CanceledTile(operation: 'saveFile'),
          ],
        ),
      ),
    );
  }
}
