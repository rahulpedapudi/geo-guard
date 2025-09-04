import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_sih/models/emergency_contact.dart';
import 'package:project_sih/services/location_service.dart';

/// The main dashboard of the app, providing a quick overview of the user's safety status.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// The user's current position.
  Position? _currentPosition;

  /// The user's current city and region.
  String _currentAddress = "Loading...";

  /// Whether the location is currently being fetched.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  /// Gets the user's current location and updates the state.
  Future<void> _getLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final position = await getCurrentLocation();

      if (!mounted) return;

      if (position != null) {
        await _updatePositionAndAddress(position);
      } else {
        setState(() {
          _currentAddress = "Location not available";
        });
      }
    } catch (e) {
      debugPrint("❌ Error in _getLocation: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Error fetching location";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Updates the state with the new position and fetches the address.
  Future<void> _updatePositionAndAddress(Position position) async {
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
    });

    if (kIsWeb) {
      setState(() {
        _currentAddress =
            "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
      });
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _currentAddress =
              "${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}";
        });
      } else {
        setState(() {
          _currentAddress =
              "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        });
      }
    } catch (e) {
      debugPrint("⚠️ Geocoding failed: $e");
      if (mounted) {
        setState(() {
          _currentAddress =
              "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoGuard'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Status: Safe ✅',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'GeoGuard is active in the background. Your location remains private.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contextual Information Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      label: 'Current Area:',
                      value: _isLoading ? 'Loading...' : _currentAddress,
                    ),
                    const Divider(),
                    _buildEmergencyContactsList(),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // SOS Button Area
            Column(
              children: [
                const Text(
                  'In an emergency, press and hold.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // SOS button logic
                    final locationText = _currentPosition != null
                        ? "Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}"
                        : "Location: Not available";

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('SOS alert sent!\n$locationText'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(64),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// A helper widget to build the list of emergency contacts.
  Widget _buildEmergencyContactsList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<EmergencyContact>('emergency_contacts').listenable(),
      builder: (context, Box<EmergencyContact> box, _) {
        final contacts = box.values.toList();
        if (contacts.isEmpty) {
          return _buildInfoRow(
            context,
            label: 'Emergency Contacts:',
            value: 'No contacts added yet.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(contact.name),
                  subtitle: Text(contact.phoneNumber),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// A helper widget to build a row of information with a label and a value.
  Widget _buildInfoRow(
    BuildContext context,
    {
    required String label,
    required String value,
  }
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
