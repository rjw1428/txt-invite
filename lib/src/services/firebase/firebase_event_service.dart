import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/event_service.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/models/rsvp.dart';

class FirebaseEventService implements EventService {
  final FirebaseFirestore _firestore;

  FirebaseEventService._internal() : _firestore = FirebaseFirestore.instance;

  FirebaseEventService() : this._internal();

  @override
  Future<Event> createEvent(Event event) async {
    final doc = _firestore.collection('events').doc();
    await doc.set(event.toMap());
    return event.copyWith(id: doc.id);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  @override
  Future<Event?> getEvent(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return Event.fromMap({'id': doc.id, ...doc.data()!});
    }
    return null;
  }

  @override
  Future<List<Event>> getActiveEvents(String uid, DateTime filterTime) async {
    final snapshot =
        await _firestore
            .collection('events')
            .where('createdBy', isEqualTo: uid)
            .where('endTime', isGreaterThanOrEqualTo: filterTime)
            .where('status', isEqualTo: EventStatus.active.toString())
            .get();
    return snapshot.docs.map((doc) {
      return Event.fromMap({'id': doc.id, ...doc.data()});
    }).toList();
  }

  @override
  Future<List<Event>> getEventHistory(String uid, DateTime filterTime) async {
    final snapshot =
        await _firestore
            .collection('events')
            .where('createdBy', isEqualTo: uid)
            .get();
    return snapshot.docs.map((doc) {
      return Event.fromMap({'id': doc.id, ...doc.data()});
    }).where((event) => event.startTime.isBefore(filterTime) || event.status == EventStatus.cancelled).toList();
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  @override
  Future<void> updateRsvp({
    required String eventId,
    required String guestId,
    required RsvpStatus status,
  }) async {
    final rsvp = Rsvp(id: guestId, status: status);

    final eventRef = _firestore.collection('events').doc(eventId);
    final eventDoc = await eventRef.get();

    if (!eventDoc.exists) {
      throw Exception('Event not found');
    }
    final eventData = {'id': eventId, ...eventDoc.data()!};
    final event = Event.fromMap(eventData);
    final guestRef = _firestore
        .collection('guest_lists')
        .doc(event.guestListId);
    final guestDoc = await guestRef.get();
    if (!guestDoc.exists) {
      throw Exception('Guest List not found');
    }

    final guestData = {'id': event.guestListId, ...guestDoc.data()!};
    final guests = GuestList.fromMap(guestData).guests;
    try {
      // Verify guest is in the guest list
      guests.firstWhere((guest) => guest.id == guestId);
    } catch (e) {
      throw Exception('Guest not found in Guest List');
    }

    // If guestId is already in the rsvps, remove it before adding
    final currentRsvps = event.rsvps;
    if (currentRsvps.any((r) => r.id == guestId)) {
      await eventRef.update({
        'rsvps': FieldValue.arrayRemove([
          currentRsvps.firstWhere((r) => r.id == guestId).toMap(),
        ]),
      });
    }
    await eventRef.update({
      'rsvps': FieldValue.arrayUnion([rsvp.toMap()]),
    });
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': EventStatus.cancelled.toString(),
    });
  }
}
