
// lib/widgets/sos_button.dart
import 'package:flutter/material.dart';

/// A widget that displays an SOS button.
class SosButton extends StatelessWidget {
  /// The callback that is called when the button is pressed.
  final VoidCallback onPressed;

  const SosButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(24),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: Text('SOS'),
    );
  }
}
