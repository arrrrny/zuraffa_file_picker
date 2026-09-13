import 'package:flutter/material.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

/// Renders one [PickedFile]: an icon for its MIME family, the name, a
/// humanized size, and the path the app can read it from.
class PickedFileTile extends StatelessWidget {
  const PickedFileTile({super.key, required this.file});

  final PickedFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(_iconFor(file.mimeType), size: 24),
      title: Text(file.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${humanizeBytes(file.size)} · ${file.mimeType ?? "unknown type"}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Tooltip(
        message: file.path,
        child: Icon(Icons.description_outlined, size: 18, color: theme.hintColor),
      ),
    );
  }

  static IconData _iconFor(String? mimeType) {
    final mime = mimeType ?? '';
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime.startsWith('video/')) return Icons.movie_outlined;
    if (mime.startsWith('audio/')) return Icons.audiotrack_outlined;
    if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

/// A "the user dismissed the picker" placeholder.
class CanceledTile extends StatelessWidget {
  const CanceledTile({super.key, required this.operation});

  final String operation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(Icons.cancel_outlined, size: 18, color: theme.hintColor),
      title: Text(
        '$operation — canceled (empty result / null path, never an exception)',
        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

/// Human-readable byte sizes for the result tiles.
String humanizeBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
