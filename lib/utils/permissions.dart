
// lib/utils/permissions.dart
import 'package:permission_handler/permission_handler.dart';

/// A utility class for handling permissions.
class Permissions {
  /// Requests location permission.
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }
}
