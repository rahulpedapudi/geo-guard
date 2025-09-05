import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// A custom exception to indicate that location permissions have been denied.
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);
}

/// A service that provides a stream of location updates.
class LocationService {
  final Stream<Position> positionStream;

  LocationService() : positionStream = _createPositionStream();

  static Stream<Position> _createPositionStream() {
    late StreamController<Position> streamController;
    StreamSubscription<Position>? positionStreamSubscription;

    streamController = StreamController<Position>(
      onListen: () async {
        try {
          final initialPosition = await _getCurrentLocation();
          if (initialPosition != null) {
            streamController.add(initialPosition);
          }

          const locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 20,
          );

          positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position? position) {
              if (position != null) {
                streamController.add(position);
              }
            },
            onError: (error) {
              debugPrint("❌ Position stream error: $error");
              streamController.addError(error);
            },
          );
        } catch (e) {
          debugPrint("❌ Error initializing location stream: $e");
          streamController.addError(e);
        }
      },
      onCancel: () {
        positionStreamSubscription?.cancel();
      },
    );

    return streamController.stream;
  }

  static Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationPermissionException("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // On web, we can't request permission here without a user gesture.
        // We throw a specific exception to be handled by the UI.
        if (kIsWeb) {
          throw LocationPermissionException(
            "Location permission denied. Please grant permission in your browser settings and refresh.",
          );
        }
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionException("Location permission denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionException("Location permissions are permanently denied.");
      }

      debugPrint("📍 Attempting to get position...");
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: kIsWeb ? 15 : 10),
      );

      debugPrint(
        "✅ Position obtained: ${position.latitude}, ${position.longitude}",
      );
      return position;
    } catch (e) {
      debugPrint("❌ Error getting current location: $e");
      // Re-throw custom exceptions to be handled by the UI
      if (e is LocationPermissionException) {
        rethrow;
      }
      return null;
    }
  }
}