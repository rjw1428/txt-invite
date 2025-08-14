import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/event_service.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/rsvp.dart';

class FirebaseEventService implements EventService {

  final FirebaseFirestore _firestore;

  FirebaseEventService._internal()
      : _firestore = FirebaseFirestore.instance;

  FirebaseEventService() : this._internal();
  
  @override
  Future<Event> createEvent(Event event) async {
    final doc = _firestore.collection('events').doc();
    final newEvent = event.copyWith(id: doc.id);
    await doc.set(newEvent.toMap());
    return newEvent;
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
  Future<List<Event>> getEvents(String uid, DateTime filterTime) async {
    final snapshot = await _firestore.collection('events').where('createdBy', isEqualTo: uid).where('startTime', isGreaterThanOrEqualTo: filterTime).get();
    return snapshot.docs.map((doc) {
      return Event.fromMap({'id': doc.id, ...doc.data()});
    }).toList();
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  @override
  Future<void> updateRsvp({required String eventId, required String guestId, required RsvpStatus status}) async {
    final rsvp = Rsvp(id: guestId, attending: status);
    
    final eventRef = _firestore.collection('events').doc(eventId);
    final eventDoc = await eventRef.get();

    if (!eventDoc.exists) {
      throw Exception('Event not found');
    }

    final guestListId = Event.fromMap(eventDoc.data()!).guestListId;
    final guestRef = _firestore.collection('guest_lists').doc(guestListId).collection('guests').doc(guestId);
    final guestDoc = await guestRef.get();

    if (!guestDoc.exists) {
      throw Exception('Guest not found');
    }

    // If guestId is already in the rsvps, remove it before adding
    final currentRsvps = eventDoc.data()!['rsvps'];
    if (currentRsvps != null) {
      final existingRsvps = (currentRsvps as List).map((e) => Rsvp.fromMap(e)).toList();
      if (existingRsvps.any((r) => r.id == guestId)) {
        await eventRef.update({
          'rsvps': FieldValue.arrayRemove([existingRsvps.firstWhere((r) => r.id == guestId).toMap()])
        });
      }
    

      await eventRef.update({
        'rsvps': FieldValue.arrayUnion([rsvp.toMap()])
      });
    }
  }
}