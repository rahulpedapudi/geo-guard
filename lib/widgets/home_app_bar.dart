import 'package:flutter/material.dart';
import 'package:project_sih/screens/settings_screen.dart';

/// A custom app bar for the home screen.
///
/// This app bar displays the title of the app and provides actions to refresh
/// the user's location and navigate to the settings screen.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// A callback function that is called when the refresh button is pressed.
  final VoidCallback onRefresh;

  /// Creates a new [HomeAppBar] widget.
  const HomeAppBar({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: const Text('GeoGuard'),
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      actions: [
        // Refresh button to get the user's current location.
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Refresh Location',
        ),
        // Settings button to navigate to the settings screen.
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  /// The preferred size of the app bar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}