// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:project_sih/screens/onboarding/emergency_contacts.dart';
// import 'package:project_sih/services/inactivity_service.dart';

/// A screen that allows the user to configure the app's settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final InactivityService _inactivityService = InactivityService();
  double _inactivityHours = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Send an alert if I am inactive for more than:'),
            Slider(
              value: _inactivityHours,
              min: 1,
              max: 24,
              divisions: 23,
              label: '${_inactivityHours.round()} hours',
              onChanged: (value) {
                setState(() {
                  _inactivityHours = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // _inactivityService.startTimer(Duration(hours: _inactivityHours.round()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Inactivity timer set to ${_inactivityHours.round()} hours',
                    ),
                  ),
                );
              },
              child: Text('Save Inactivity Timer'),
            ),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmergencyContacts(
                      onFinish: () => Navigator.pop(context),
                      onPrevious: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              child: const Text('Update Emergency Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}
