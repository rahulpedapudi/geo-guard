// lib/screens/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_sih/widgets/sos_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_sih/services/location_service.dart';
import 'settings_screen.dart';

/// The home screen of the app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String _currentCity = "Loading...";
  String _currentRegion = "Loading...";
  bool _isLoading = true;
  String? _errorMessage;

  // Default fallback location (New Delhi for example)
  static const LatLng _fallbackLocation = LatLng(28.6139, 77.2090);

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await getCurrentLocation();

      if (position == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to get location. Using default location.";
          _currentCity = "Default Location";
          _currentRegion = "Enable location for accuracy";
        });
        return;
      }

      if (position.latitude == 0.0 && position.longitude == 0.0) {
        debugPrint("⚠️ Invalid position coordinates.");
        setState(() {
          _isLoading = false;
          _errorMessage = "Invalid location data received.";
          _currentCity = "Location Error";
          _currentRegion = "Please try again";
        });
        return;
      }

      // Update position first
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Try to get address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => <Placemark>[],
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          setState(() {
            _currentCity = placemark.locality ?? 
                          placemark.subAdministrativeArea ?? 
                          "Unknown city";
            _currentRegion = placemark.administrativeArea ?? 
                            placemark.country ?? 
                            "Unknown region";
          });
          debugPrint("✅ Address: $_currentCity, $_currentRegion");
        } else {
          setState(() {
            _currentCity = "Lat: ${position.latitude.toStringAsFixed(4)}";
            _currentRegion = "Lng: ${position.longitude.toStringAsFixed(4)}";
          });
          debugPrint("⚠️ No address found, showing coordinates");
        }
      } catch (e) {
        debugPrint("⚠️ Geocoding failed: $e");
        setState(() {
          _currentCity = "Lat: ${position.latitude.toStringAsFixed(4)}";
          _currentRegion = "Lng: ${position.longitude.toStringAsFixed(4)}";
        });
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Location error: ${e.toString()}";
        _currentCity = "Error";
        _currentRegion = "Please check permissions";
      });
    }
  }

  LatLng get _mapCenter {
    if (_currentPosition != null) {
      return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    return _fallbackLocation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Tourist Safety'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getLocation,
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app', // Required for web
                maxNativeZoom: 19,
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Location Info Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading
                              ? Icons.location_searching
                              : _errorMessage != null
                                  ? Icons.location_off
                                  : Icons.location_on,
                          color: _isLoading
                              ? theme.colorScheme.primary
                              : _errorMessage != null
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isLoading)
                                const Text(
                                  "Getting your location...",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              else if (_errorMessage != null)
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                  "$_currentCity, $_currentRegion",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              if (_currentPosition != null && !_isLoading)
                                Text(
                                  "Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(0)}m",
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        if (_isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Platform-specific warning for web
          if (kIsWeb && _errorMessage != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Web browsers may block location access. Please enable location permissions.",
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // SOS Button
          Positioned(
            bottom: 32,
            right: 32,
            child: SosButton(
              onPressed: () {
                final locationText = _currentPosition != null
                    ? "Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}"
                    : "Location: Not available";
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('SOS alert sent!\n$locationText'),
                    duration: const Duration(seconds: 3),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}