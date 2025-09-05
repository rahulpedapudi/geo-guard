import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_sih/models/emergency_contact.dart';
import 'package:project_sih/services/location_service.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<String> _getAddressFromPosition(Position position) async {
    if (kIsWeb) {
      return "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return "${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}";
      } else {
        return "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
      }
    } catch (e) {
      debugPrint("⚠️ Geocoding failed: $e");
      return "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    Position? position;
    String? errorMessage;

    try {
      position = Provider.of<Position?>(context);
    } on LocationPermissionException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "An unexpected error occurred.";
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
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
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (errorMessage != null)
                        _buildInfoRow(
                          context,
                          label: 'Current Area:',
                          value: errorMessage,
                          valueColor: Theme.of(context).colorScheme.error,
                        )
                      else
                        FutureBuilder<String>(
                          future: position != null
                              ? _getAddressFromPosition(position)
                              : Future.value("Loading..."),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildInfoRow(
                                context,
                                label: 'Current Area:',
                                value: 'Loading...',
                              );
                            }
                            return _buildInfoRow(
                              context,
                              label: 'Current Area:',
                              value: snapshot.data ?? "Not available",
                            );
                          },
                        ),
                      const Divider(),
                      _buildEmergencyContactsList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Text(
                    'In an emergency, press and hold.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final locationText = position != null
                          ? "Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}"
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<EmergencyContact>(
        'emergency_contacts',
      ).listenable(),
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

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
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
              style: TextStyle(fontSize: 16, color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
