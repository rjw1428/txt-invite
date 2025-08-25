
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/models/event_settings.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/rsvp.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String invitationImageUrl;
  final String invitationImageThumbnailUrl;
  final String createdBy;
  final int attendingCount;
  final int notAttendingCount;
  final int maybeCount;
  final int inviteCount;
  final EventStatus status;
  final EventSettings settings;
  final List<Guest> guestList;
  final String? qrCodeImageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.invitationImageUrl,
    required this.invitationImageThumbnailUrl,
    required this.createdBy,
    required this.settings,
    this.attendingCount = 0,
    this.notAttendingCount = 0,
    this.maybeCount = 0,
    this.inviteCount = 0,
    this.status = EventStatus.active,
    this.guestList = const [],
    this.qrCodeImageUrl,
  });

  Map<RsvpStatus, int> get rsvpCounts {
    final counts = <RsvpStatus, int>{
      RsvpStatus.attending: attendingCount,
      RsvpStatus.notAttending: notAttendingCount,
      RsvpStatus.maybe: maybeCount,
      RsvpStatus.pending: inviteCount - (attendingCount + notAttendingCount + maybeCount),
    };
    return counts;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? invitationImageUrl,
    String? invitationImageThumbnailUrl,
    String? createdBy,
    int? attendingCount,
    int? notAttendingCount,
    int? maybeCount,
    int? inviteCount,
    EventStatus? status,
    EventSettings? settings,
    List<Guest>? guestList,
    String? qrCodeImageUrl,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      invitationImageUrl: invitationImageUrl ?? this.invitationImageUrl,
      invitationImageThumbnailUrl: invitationImageThumbnailUrl ?? this.invitationImageThumbnailUrl,
      createdBy: createdBy ?? this.createdBy,
      attendingCount: attendingCount ?? this.attendingCount,
      notAttendingCount: notAttendingCount ?? this.notAttendingCount,
      maybeCount: maybeCount ?? this.maybeCount,
      inviteCount: inviteCount ?? this.inviteCount,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      guestList: guestList ?? this.guestList,
      qrCodeImageUrl: qrCodeImageUrl ?? this.qrCodeImageUrl,
    );
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      invitationImageUrl: map['invitationImageUrl'],
      invitationImageThumbnailUrl: map['invitationImageThumbnailUrl'],
      createdBy: map['createdBy'],
      attendingCount: map['attendingCount'] ?? 0,
      notAttendingCount: map['notAttendingCount'] ?? 0,
      maybeCount: map['maybeCount'] ?? 0,
      inviteCount: map['inviteCount'] ?? 99,
      status: EventStatus.values.firstWhere((e) => e.toString() == map['status'], orElse: () => EventStatus.active),
      settings: EventSettings.fromMap(map['settings'] ?? {}),
      guestList: (map['guestList'] as List<dynamic>?)?.map((e) => Guest.fromMap(e)).toList() ?? [],
      qrCodeImageUrl: map['qrCodeImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'invitationImageUrl': invitationImageUrl,
      'invitationImageThumbnailUrl': invitationImageThumbnailUrl,
      'qrCodeImageUrl': qrCodeImageUrl,
      'createdBy': createdBy,
      'attendingCount': attendingCount,
      'notAttendingCount': notAttendingCount,
      'maybeCount': maybeCount,
      'inviteCount': inviteCount,
      'status': status.toString(),
      'settings': settings.toMap(),
    };
  }
}
