import 'package:flutter/material.dart';
import 'package:project_sih/screens/initial_onboarding.dart';
import 'package:project_sih/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('onboarding_complete') ?? true;
  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Tourist Safety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: showOnboarding ? const InitialOnboarding() : const MainScreen(),
    );
  }
}
