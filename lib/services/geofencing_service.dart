
// // lib/services/geofencing_service.dart
// import 'dart:async';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:project_sih/models/unsafe_zone.dart';
// import 'package:project_sih/services/location_service.dart';

// /// A service that handles geofencing.
// class GeofencingService {
//   final LocationService _locationService = LocationService();
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Hardcoded list of unsafe zones for the MVP.
//   final List<UnsafeZone> _unsafeZones = [
//     UnsafeZone(
//       name: 'High-Risk Area',
//       points: [
//         LatLng(28.615, 77.21),
//         LatLng(28.615, 77.22),
//         LatLng(28.61, 77.22),
//         LatLng(28.61, 77.21),
//       ],
//     ),
//   ];

//   /// Initializes the geofencing service.
//   Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   /// Starts monitoring the user's location.
//   void startMonitoring() {
//     // In a real app, you would use a background task to periodically check the
//     // user's location.
//     Timer.periodic(Duration(seconds: 5), (timer) async {
//       final currentLocation = await _locationService.getCurrentLocation();
//       _checkIfInUnsafeZone(currentLocation);
//     });
//   }

//   void _checkIfInUnsafeZone(LatLng currentLocation) {
//     for (final zone in _unsafeZones) {
//       if (_isPointInPolygon(currentLocation, zone.points)) {
//         _showUnsafeZoneNotification(zone);
//       }
//     }
//   }

//   bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
//     int intersectCount = 0;
//     for (int j = 0; j < polygon.length - 1; j++) {
//       if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
//         intersectCount++;
//       }
//     }
//     return (intersectCount % 2) == 1; // odd = inside, even = outside;
//   }

//   bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
//     double aY = vertA.latitude;
//     double bY = vertB.latitude;
//     double aX = vertA.longitude;
//     double bX = vertB.longitude;
//     double pY = point.latitude;
//     double pX = point.longitude;

//     if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
//       return false; // a and b can't both be above or below pt.y, and a or
//       // b must be east of pt.x
//     }

//     double m = (aY - bY) / (aX - bX); // Rise over run
//     double bee = (-aX * m) + aY; // y = mx + b
//     double x = (pY - bee) / m; // algebra is neat!

//     return x > pX;
//   }

//   Future<void> _showUnsafeZoneNotification(UnsafeZone zone) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'unsafe_zone_channel',
//       'Unsafe Zone Alerts',
//       channelDescription: 'Notifications for when you enter an unsafe zone',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: false,
//     );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       'Warning: Unsafe Zone',
//       'You are entering the ${zone.name}.',
//       platformChannelSpecifics,
//     );
//   }
// }
