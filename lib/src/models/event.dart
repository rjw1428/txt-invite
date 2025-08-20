
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/models/event_settings.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/rsvp.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String guestListId;
  final String invitationImageUrl;
  final String invitationImageThumbnailUrl;
  final String createdBy;
  final List<Rsvp> rsvps;
  final int inviteCount;
  final EventStatus status;
  final EventSettings settings;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.guestListId,
    required this.invitationImageUrl,
    required this.invitationImageThumbnailUrl,
    required this.createdBy,
    required this.settings,
    this.rsvps = const [],
    this.inviteCount = 0,
    this.status = EventStatus.active,
  });

  Map<RsvpStatus, int> get rsvpCounts {
    final counts = <RsvpStatus, int>{
      RsvpStatus.attending: rsvps.where((rsvp) => rsvp.status == RsvpStatus.attending).length,
      RsvpStatus.notAttending: rsvps.where((rsvp) => rsvp.status == RsvpStatus.notAttending).length,
      RsvpStatus.maybe: rsvps.where((rsvp) => rsvp.status == RsvpStatus.maybe).length,
      RsvpStatus.pending: inviteCount - rsvps.length,
    };
    return counts;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? guestListId,
    String? invitationImageUrl,
    String? invitationImageThumbnailUrl,
    String? createdBy,
    List<Rsvp>? rsvps,
    int? inviteCount,
    EventStatus? status,
    EventSettings? settings,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      guestListId: guestListId ?? this.guestListId,
      invitationImageUrl: invitationImageUrl ?? this.invitationImageUrl,
      invitationImageThumbnailUrl: invitationImageThumbnailUrl ?? this.invitationImageThumbnailUrl,
      createdBy: createdBy ?? this.createdBy,
      rsvps: rsvps ?? this.rsvps,
      inviteCount: inviteCount ?? this.inviteCount,
      status: status ?? this.status,
      settings: settings ?? this.settings,
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
      invitationImageThumbnailUrl: map['invitationImageThumbnailUrl'],
      createdBy: map['createdBy'],
      rsvps: (map['rsvps'] as List<dynamic>).map((e) => Rsvp.fromMap(e)).toList(),
      inviteCount: map['inviteCount'] ?? 99,
      status: EventStatus.values.firstWhere((e) => e.toString() == map['status'], orElse: () => EventStatus.active),
      settings: EventSettings.fromMap(map['settings'] ?? {}),
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
      'invitationImageThumbnailUrl': invitationImageThumbnailUrl,
      'createdBy': createdBy,
      'rsvps': rsvps.map((rsvp) => rsvp.toMap()).toList(),
      'inviteCount': inviteCount,
      'status': status.toString(),
      'settings': settings.toMap(),
    };
  }
}
