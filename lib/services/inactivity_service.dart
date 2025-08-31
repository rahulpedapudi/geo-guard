// // lib/services/inactivity_service.dart
// import 'dart:async';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// /// A service that handles inactivity monitoring.
// class InactivityService {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Timer? _inactivityTimer;

//   /// Initializes the inactivity service.
//   Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   /// Starts the inactivity timer.
//   void startTimer(Duration duration) {
//     _inactivityTimer?.cancel();
//     _inactivityTimer = Timer(duration, () {
//       _showInactivityAlert();
//     });
//   }

//   /// Stops the inactivity timer.
//   void stopTimer() {
//     _inactivityTimer?.cancel();
//   }

//   Future<void> _showInactivityAlert() async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'inactivity_channel',
//           'Inactivity Alerts',
//           channelDescription:
//               'Notifications for when you are inactive for too long',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: false,
//         );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await _flutterLocalNotificationsPlugin.show(
//       1,
//       'Inactivity Alert',
//       'You have been inactive for your selected duration. An alert has been sent to your emergency contacts.',
//       platformChannelSpecifics,
//     );
//   }
// }
