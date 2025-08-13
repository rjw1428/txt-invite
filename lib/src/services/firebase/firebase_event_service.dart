import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/event_service.dart';
import 'package:txt_invite/src/models/event.dart';

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
  }