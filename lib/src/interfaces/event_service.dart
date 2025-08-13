
import '../models/event.dart';

abstract class EventService {
  Future<Event> createEvent(Event event);
  Future<Event?> getEvent(String eventId);
  Future<List<Event>> getEvents(String uid, DateTime filterTime);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
}
