import 'package:flutter/material.dart';

import 'picker_controller.dart';

/// The running record of every operation the app performed, newest first —
/// the visible contract between the panels and the port.
class FlowLogView extends StatelessWidget {
  const FlowLogView({super.key, required this.entries});

  final List<FlowEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No operations yet — pick, save or browse to fill the log.',
          style: theme.textTheme.bodySmall,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          dense: true,
          leading: Icon(
            entry.isError ? Icons.error_outline : Icons.check_circle_outline,
            color: entry.isError ? theme.colorScheme.error : Colors.green,
            size: 18,
          ),
          title: Text(
            entry.text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}
