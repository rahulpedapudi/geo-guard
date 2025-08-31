import 'package:flutter/material.dart';
import 'package:project_sih/screens/home_screen.dart';
import 'package:project_sih/screens/onboarding/emergency_contacts.dart';
import 'package:project_sih/screens/onboarding/privacy_page.dart';
import 'package:project_sih/screens/onboarding/safety_rules.dart';
import 'package:project_sih/screens/onboarding/welcome.dart';

class InitialOnboarding extends StatefulWidget {
  const InitialOnboarding({super.key});

  @override
  State<InitialOnboarding> createState() => _InitialOnboardingState();
}

class _InitialOnboardingState extends State<InitialOnboarding> {
  final PageController _pageController = PageController();

  void _goToNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _goToPrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
        children: [
          Welcome(onNext: _goToNext),
          SafetyRules(onNext: _goToNext, onPrevious: _goToPrevious),
          PrivacyPage(onNext: _goToNext, onPrevious: _goToPrevious),
          EmergencyContacts(onFinish: _finishOnboarding, onPrevious: _goToPrevious),
        ],
      ),
    );
  }
}