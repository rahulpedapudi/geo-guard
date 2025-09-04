// // lib/models/emergency_contact.dart

// /// Represents an emergency contact.
// class EmergencyContact {
//   /// The name of the contact.
//   final String name;

//   /// The phone number of the contact.
//   final String phoneNumber;

//   EmergencyContact({required this.name, required this.phoneNumber});
// }
import 'package:hive/hive.dart';
part 'emergency_contact.g.dart';

@HiveType(typeId: 0)
class EmergencyContact {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phoneNumber;

  EmergencyContact(this.name, this.phoneNumber);
}
