
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String guestListId;
  final String invitationImageUrl;
  final String createdBy;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.guestListId,
    required this.invitationImageUrl,
    required this.createdBy,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? guestListId,
    String? invitationImageUrl,
    String? createdBy,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      guestListId: guestListId ?? this.guestListId,
      invitationImageUrl: invitationImageUrl ?? this.invitationImageUrl,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      guestListId: (map['guestListId'] as DocumentReference).id,
      invitationImageUrl: map['invitationImageUrl'],
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'guestListId': FirebaseFirestore.instance.collection('guest_lists').doc(guestListId),
      'invitationImageUrl': invitationImageUrl,
      'createdBy': createdBy,
    };
  }
}
