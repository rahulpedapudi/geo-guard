import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  final VoidCallback onNext;

  const Welcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              "Welcome to GeoGuard",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Your personal safety companion for exploring the world with confidence.",
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text("Get Started"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
