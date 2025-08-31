import 'package:flutter/material.dart';
import 'package:project_sih/utils/permissions.dart';

class PrivacyPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PrivacyPage({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _isPermissionGranted = false;

  Future<void> _requestPermission() async {
    final hasPermission = await Permissions.requestLocationPermission();
    setState(() {
      _isPermissionGranted = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              "Your Privacy is Our Priority",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            Text(
              "Your location data never leaves your device unless you declare an emergency. We can't see it. No one can.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text("Grant Location Permission"),
            ),
            SizedBox(height: 10),
            if (_isPermissionGranted)
              const Text(
                "Permission Granted!",
                style: TextStyle(color: Colors.green),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onPrevious,
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: _isPermissionGranted ? widget.onNext : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
