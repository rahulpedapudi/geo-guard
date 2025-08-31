
// lib/models/unsafe_zone.dart
import 'package:latlong2/latlong.dart';

/// Represents an unsafe zone defined by a polygon.
class UnsafeZone {
  /// The name of the zone.
  final String name;

  /// The list of points that define the polygon of the zone.
  final List<LatLng> points;

  UnsafeZone({required this.name, required this.points});
}
