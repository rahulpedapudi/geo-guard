import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A widget that displays the map layer.
///
/// This widget uses the `flutter_map` package to display an OpenStreetMap
/// tile layer. It also displays a marker at the user's current location.
class MapLayerWidget extends StatelessWidget {
  /// The center of the map.
  final LatLng mapCenter;

  /// The user's current location.
  final LatLng? currentPosition;

  /// Creates a new [MapLayerWidget] widget.
  const MapLayerWidget({
    super.key,
    required this.mapCenter,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FlutterMap(
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: 13.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        // The OpenStreetMap tile layer.
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app', // Required for web
          maxNativeZoom: 19,
        ),
        // A marker that indicates the user's current location.
        if (currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition!,
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
    );
  }
}