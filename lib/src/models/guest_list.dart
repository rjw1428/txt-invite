import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/models/guest.dart';

class GuestList {
  final String? id;
  final String name;
  final List<Guest> guests;
  final String createdBy;
  final DateTime createdAt;

  GuestList({this.id, required this.name, required this.guests, required this.createdBy, required this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdBy': createdBy,
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
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory GuestList.fromMap(Map<String, dynamic> data) {
    return GuestList(
      id: data['id'],
      name: data['name'],
      guests: List<Guest>.from(data['guests'].map((guest) => Guest.fromMap(guest))),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  GuestList copyWith({required String id, String? name, List<Guest>? guests, String? createdBy, DateTime? createdAt}) {
    return GuestList(
      id: id,
      name: name ?? this.name,
      guests: guests ?? this.guests,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}