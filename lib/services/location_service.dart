// lib/services/location_service.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  try {
    // Web-specific handling
    if (kIsWeb) {
      debugPrint("🌐 Running on web platform");

      // Check if geolocation is supported
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("❌ Location services not supported or disabled in browser");
        return null;
      }

      // Web browsers handle permissions differently
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("🔐 Current permission status: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint("🔐 Permission after request: $permission");

        if (permission == LocationPermission.denied) {
          debugPrint("❌ Location permission denied by user");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("❌ Location permissions permanently denied");
        return null;
      }

      // Get position with web-friendly settings
      debugPrint("📍 Attempting to get position...");
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Longer timeout for web
      );

      debugPrint(
        "✅ Position obtained: ${position.latitude}, ${position.longitude}",
      );
      debugPrint("📊 Accuracy: ${position.accuracy}m");
      return position;
    }
    // Mobile platform handling (original logic)
    else {
      debugPrint("📱 Running on mobile platform");

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("❌ Location services are disabled");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("❌ Location permissions denied");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("❌ Location permissions permanently denied");
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        "✅ Position obtained: ${position.latitude}, ${position.longitude}",
      );
      return position;
    }
  } catch (e) {
    debugPrint("❌ Error getting current location: $e");

    // Provide more specific error messages
    if (e.toString().contains('User denied')) {
      debugPrint("🚫 User explicitly denied location permission");
    } else if (e.toString().contains('TIMEOUT')) {
      debugPrint("⏰ Location request timed out");
    } else if (e.toString().contains('PERMISSION_DENIED')) {
      debugPrint("🔒 Location permission was denied");
    }

    return null;
  }
}
