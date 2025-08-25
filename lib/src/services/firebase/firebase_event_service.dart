import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/event_service.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/paginated_result.dart';
import 'package:txt_invite/src/models/rsvp.dart';
import 'package:txt_invite/src/utils/constants.dart';

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
  Future<PaginatedResult<Event>> getActiveEvents(String uid, DateTime filterTime, DocumentSnapshot? lastDocument) async {
    var query = _firestore
        .collection('events')
        .where('createdBy', isEqualTo: uid)
        .where('endTime', isGreaterThanOrEqualTo: filterTime)
        .where('status', isEqualTo: EventStatus.active.toString())
        .orderBy('startTime')
        .limit(5);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      return PaginatedResult(results: []);
    }

    final events = snapshot.docs.map((doc) {
      return Event.fromMap({'id': doc.id, ...doc.data()});
    }).toList();

    return PaginatedResult(results: events, lastDocument: snapshot.docs.last);
  }

  @override
  Future<PaginatedResult<Event>> getEventHistory(String uid, DateTime filterTime, DocumentSnapshot? lastDocument) async {
    var query = _firestore
        .collection('events')
        .where('createdBy', isEqualTo: uid)
        .orderBy('startTime', descending: true)
        .limit(5);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      return PaginatedResult(results: [], lastDocument: null);
    }

    final docs = snapshot.docs.map((doc) {
      return Event.fromMap({'id': doc.id, ...doc.data()});
    }).where((event) => event.startTime.isBefore(filterTime) || event.status == EventStatus.cancelled).toList();

    return PaginatedResult(results: docs, lastDocument: snapshot.docs.last);
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  @override
  Future<Rsvp?> getRsvp(String eventId, String guestId) async {
    final rsvpRef = _firestore.collection('events').doc(eventId).collection('rsvps').doc(guestId);
    final snapshot = await rsvpRef.get();

    if (!snapshot.exists) {
      return null;
    }

    return Rsvp.fromMap({'id': snapshot.id, ...snapshot.data()!});
  }

  @override
  Future<List<Rsvp>> getRsvps(String eventId) async {
    final rsvpsRef = _firestore.collection('events').doc(eventId).collection('rsvps');
    final snapshot = await rsvpsRef.get();
    if (snapshot.docs.isEmpty) {
      return [];
    }
    return snapshot.docs.map((doc) => Rsvp.fromMap({'id': doc.id, ...doc.data()})).toList();
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

    // Make sure the event exists
    if (!eventDoc.exists) {
      throw Exception('Event not found');
    }

    final guestListSnapshot = await eventRef.collection('guestList').get();
    if (guestListSnapshot.docs.isEmpty) {
      throw Exception('Guest List not found for this event');
    }

    // Make sure guest exists
    final guestDoc = await eventRef.collection('guestList').doc(guestId).get();
    if (!guestDoc.exists) {
      throw Exception('Guest not found in Guest List');
    }

    // Write RSVP/UPDATE
    final rsvpRef = eventRef.collection('rsvps').doc(guestId);
    // final rsvpDoc = await rsvpRef.get(); // Should not matter if it exists or not
    await rsvpRef.set(rsvp.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': EventStatus.cancelled.toString(),
    });
  }

  @override
  Future<List<Guest>> addGuestListToEvent(String eventId, List<Guest> guestList) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final guestListCollectionRef = eventRef.collection('guestList');

    return Future.wait(guestList.map((guest) async {
      final doc = guestListCollectionRef.doc();
      final guestWithId = guest.copyWith(id: doc.id);
      await doc.set(guestWithId.toJson());
      return guestWithId;
    }));
  }

 @override
  Future<Guest> addGuest(String eventId, Guest guest) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final guestListCollectionRef = eventRef.collection('guestList');

    final doc = guestListCollectionRef.doc();
    final guestWithId = guest.copyWith(id: doc.id);
    await doc.set(guestWithId.toJson());
    await eventRef.update({
      'inviteCount': FieldValue.increment(1),
    });
    return guestWithId;
  }

  @override
  Future<List<Guest>> getGuests(String eventId) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final guestListCollectionRef = eventRef.collection('guestList');
    final snapshot = await guestListCollectionRef.get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    return snapshot.docs
        .map((doc) => Guest.fromMap(doc.data()))
        .where((guest) => guest.firstName != ANONYMOUS_GUEST_NAME)
        .toList();
  }

  @override
  Future<Guest?> getGuest(String eventId, String guestId) async {
    final guestRef = _firestore.collection('events').doc(eventId).collection('guestList').doc(guestId);
    final snapshot = await guestRef.get();

    if (!snapshot.exists) {
      return null;
    }

    return Guest.fromMap(snapshot.data()!);
  }
}
