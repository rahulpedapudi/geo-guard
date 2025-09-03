import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

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
    if (!mounted) return; // Avoid calling setState on unmounted widgets

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Cancel any existing stream subscription
    await _positionStream?.cancel();
    _positionStream = null;

    try {
      final position = await getCurrentLocation();

      if (!mounted) return;

      if (position == null ||
          (position.latitude == 0.0 && position.longitude == 0.0)) {
        debugPrint("⚠️ Invalid position coordinates.");
        setState(() {
          _errorMessage = "Could not fetch location. Please try again.";
          _currentCity = "Location Error";
          _currentRegion = "Enable permissions and refresh";
        });
        return;
      }

      // Update position and address
      await _updatePositionAndAddress(position);

      // Set up the new position stream
      _setupPositionStream();
    } catch (e) {
      debugPrint("❌ Error in _getLocation: $e");
      if (mounted) {
        setState(() {
          _errorMessage = " ";
          _currentCity = "Error";
          _currentRegion = "Please check permissions";
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

    // Update the current position. This will trigger a rebuild, and the map
    // will be centered correctly on the new position via the `mapCenter` getter.
    setState(() {
      _currentPosition = position;
    });

    try {
      // Fetch the address from the coordinates.
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

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
      } else {
        // If no address is found, fall back to showing coordinates.
        _showCoordinates(position);
      }
    } catch (e) {
      debugPrint("⚠️ Geocoding failed: $e");
      if (mounted) {
        _showCoordinates(position);
      }
    }
  }

  /// Sets up the position stream for continuous location updates.
  void _setupPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null && mounted) {
              // When a new position is received from the stream, update the state
              // and manually move the map to the new location.
              setState(() {
                _currentPosition = position;
              });

              _mapController.move(
                LatLng(position.latitude, position.longitude),
                _mapController.camera.zoom,
              );

              // To avoid excessive geocoding, only update the address if the
              // user has moved a significant distance.
              if (_currentPosition == null ||
                  Geolocator.distanceBetween(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        position.latitude,
                        position.longitude,
                      ) >
                      20) {
                _updatePositionAndAddress(position);
              }
            }
          },
          onError: (error) {
            debugPrint("❌ Position stream error: $error");
            if (mounted) {
              setState(() {
                _errorMessage = "Location tracking failed.";
              });
            }
          },
        );
  }

  /// Fallback to show coordinates when geocoding fails.
  void _showCoordinates(Position position) {
    setState(() {
      _currentCity = "Lat: ${position.latitude.toStringAsFixed(4)}";
      _currentRegion = "Lng: ${position.longitude.toStringAsFixed(4)}";
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // stop updates when page is destroyed
    super.dispose();
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
              mapController: _mapController,
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
