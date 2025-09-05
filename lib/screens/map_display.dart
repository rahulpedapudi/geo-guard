import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_sih/widgets/location_info_card.dart';
import 'package:project_sih/widgets/map_layer.dart';
import 'package:project_sih/widgets/sos_button.dart';
import 'package:project_sih/widgets/web_warning.dart';
import 'package:provider/provider.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({super.key});

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  final MapController _mapController = MapController();

  String _currentCity = "Loading...";
  String _currentRegion = "Loading...";
  Position? _lastPosition;

  @override
  Widget build(BuildContext context) {
    final position = Provider.of<Position?>(context);

    // We only want to move the map when the position changes.
    if (position != null && position != _lastPosition) {
      _lastPosition = position;
      _updateAddress(position);

      // Use a post-frame callback to ensure the map is rendered before moving it.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0, // Use a fixed zoom level to avoid issues with uninitialized camera
          );
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          if (position == null)
            const Center(child: CircularProgressIndicator())
          else
            MapLayerWidget(
              mapController: _mapController,
              mapCenter: LatLng(position.latitude, position.longitude),
              currentPosition: LatLng(position.latitude, position.longitude),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: LocationInfoCard(
              isLoading: position == null,
              errorMessage: null,
              currentCity: _currentCity,
              currentRegion: _currentRegion,
              currentPosition: position,
            ),
          ),
          if (kIsWeb && position == null)
            const Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: WebWarning(),
            ),
          Positioned(
            bottom: 32,
            right: 32,
            child: SosButton(
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAddress(Position position) async {
    if (kIsWeb) {
      _showCoordinates(position);
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
        _showCoordinates(position);
      }
    } catch (e) {
      debugPrint("⚠️ Geocoding failed: $e");
      if (mounted) {
        _showCoordinates(position);
      }
    }
  }

  void _showCoordinates(Position position) {
    setState(() {
      _currentCity = "Lat: ${position.latitude.toStringAsFixed(4)}";
      _currentRegion = "Lng: ${position.longitude.toStringAsFixed(4)}";
    });
  }
}