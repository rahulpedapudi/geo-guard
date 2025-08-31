// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:project_sih/utils/permissions.dart';
import 'home_screen.dart';

/// A screen that onboards the user with privacy-focused messaging and permissions.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;
  bool _permissionGranted = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final hasPermission = await Permissions.requestLocationPermission();
    setState(() {
      _permissionGranted = hasPermission;
      if (hasPermission) {
        _statusMessage = 'Location permission granted ✓';
      } else {
        _statusMessage = 'Location permission is required for safety features';
      }
    });
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting permissions...';
    });

    try {
      final hasPermission = await Permissions.requestLocationPermission();
      setState(() {
        _permissionGranted = hasPermission;
        _isLoading = false;
        if (hasPermission) {
          _statusMessage = 'Permission granted! You can now proceed.';
        } else {
          _statusMessage =
              'Permission denied. Please enable location access in settings to use safety features.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error requesting permissions. Please try again.';
      });
    }
  }

  void _proceedToHome() {
    if (!_permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required to proceed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 80, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Smart Tourist Safety',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your safety, your privacy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Privacy Information
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPrivacyCard(
                        icon: Icons.phone_android,
                        title: 'Data Stays on Your Device',
                        description:
                            'Your location and personal data are encrypted and stored only on your phone.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildPrivacyCard(
                        icon: Icons.location_on,
                        title: 'Smart Safety Monitoring',
                        description:
                            'AI-powered alerts for unsafe areas and emergency situations without compromising privacy.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildPrivacyCard(
                        icon: Icons.family_restroom,
                        title: 'Emergency Contacts',
                        description:
                            'Quick access to emergency services and your trusted contacts when needed.',
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),

              // Permission Section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _permissionGranted
                            ? colorScheme.primaryContainer
                            : colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _permissionGranted
                              ? colorScheme.primary.withOpacity(0.3)
                              : colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _permissionGranted
                                ? Icons.check_circle
                                : Icons.location_off,
                            color: _permissionGranted
                                ? colorScheme.primary
                                : colorScheme.error,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location Permission',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _permissionGranted
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _permissionGranted
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Column(
                      children: [
                        if (!_permissionGranted) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _requestPermissions,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.location_on),
                              label: Text(
                                _isLoading
                                    ? 'Requesting...'
                                    : 'Grant Permission',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _proceedToHome,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Get Started'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _permissionGranted
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              foregroundColor: _permissionGranted
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyCard({
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
