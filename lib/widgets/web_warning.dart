import 'package:flutter/material.dart';

/// A widget that displays a warning message on web platforms.
///
/// This widget is displayed when the app is running on the web and the user has
/// not granted location permissions.
class WebWarning extends StatelessWidget {
  /// Creates a new [WebWarning] widget.
  const WebWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Web browsers may block location access. Please enable location permissions.",
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}