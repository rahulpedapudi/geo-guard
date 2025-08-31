import 'package:flutter/material.dart';

class SafetyRules extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const SafetyRules({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

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
              "Automated Safety Checks",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            Text(
              "Along with the SOS button, you can set a rule to automatically alert your contacts if your phone is inactive for too long. You can configure this anytime in the settings.",
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: onPrevious, child: const Text("Back")),
                ElevatedButton(onPressed: onNext, child: const Text("Next")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
