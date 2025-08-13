import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/models/guest.dart';

class GuestList {
  final String? id;
  final String name;
  final List<Guest> guests;

  GuestList({this.id, required this.name, required this.guests});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'guests': guests.map((guest) => guest.toJson()).toList(),
    };
  }

  factory GuestList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return GuestList(
      id: doc.id,
      name: data['name'] ?? '',
      guests: (data['guests'] as List)
          .map((guestData) => Guest.fromMap(guestData))
          .toList(),
    );
  }

  factory GuestList.fromMap(Map<String, dynamic> data) {
    return GuestList(
      id: data['id'],
      name: data['name'],
      guests: List<Guest>.from(data['guests'].map((guest) => Guest.fromMap(guest))),
    );
  }

  copyWith({required String id}) {}
}