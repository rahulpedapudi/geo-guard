import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_sih/services/location_service.dart';
import 'package:project_sih/widgets/home_app_bar.dart';
import 'package:project_sih/widgets/location_info_card.dart';
import 'package:project_sih/widgets/map_layer.dart';
import 'package:project_sih/widgets/sos_button.dart';
import 'package:project_sih/widgets/web_warning.dart';

/// The home screen of the app.
///
/// This screen displays a map with the user's current location, a card with
/// location information, and an SOS button.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The user's current position.
  Position? _currentPosition;

  /// The user's current city.
  String _currentCity = "Loading...";

  /// The user's current region.
  String _currentRegion = "Loading...";

  /// Whether the location is currently being fetched.
  bool _isLoading = true;

  /// An error message to display if the location could not be fetched.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  /// Gets the user's current location and updates the state.
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await getCurrentLocation();

      if (position?.latitude == 0.0 && position?.longitude == 0.0) {
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
          position!.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10), onTimeout: () => <Placemark>[]);

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          setState(() {
            _currentCity =
                placemark.locality ??
                placemark.subAdministrativeArea ??
                "Unknown city";
            _currentRegion =
                placemark.administrativeArea ??
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
          _currentCity = "Lat: ${position?.latitude.toStringAsFixed(4)}";
          _currentRegion = "Lng: ${position?.longitude.toStringAsFixed(4)}";
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

  /// The center of the map.
  LatLng get _mapCenter {
    if (_currentPosition != null) {
      return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    return const LatLng(0, 0); // Return a default value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The app bar for the home screen.
      appBar: HomeAppBar(onRefresh: _getLocation),
      // The body of the home screen.
      body: Stack(
        children: [
          // A loading indicator that is displayed when the location is being fetched.
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          // The map layer.
          else
            MapLayerWidget(
              mapCenter: _mapCenter,
              currentPosition: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : null,
            ),
          // A card that displays information about the user's current location.
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: LocationInfoCard(
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              currentCity: _currentCity,
              currentRegion: _currentRegion,
              currentPosition: _currentPosition,
            ),
          ),
          // A warning message that is displayed on web platforms if the user has
          // not granted location permissions.
          if (kIsWeb && _errorMessage != null)
            const Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: WebWarning(),
            ),
          // The SOS button.
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
                    backgroundColor: Theme.of(context).colorScheme.error,
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
