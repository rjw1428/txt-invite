
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/rsvp.dart';

abstract class EventService {
  Future<Event> createEvent(Event event);
  Future<Event?> getEvent(String eventId);
  Future<List<Event>> getActiveEvents(String uid, DateTime filterTime);
  Future<List<Event>> getEventHistory(String uid, DateTime filterTime);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<void> updateRsvp({required String eventId, required String guestId, required RsvpStatus status});
  Future<void> cancelEvent(String eventId);
  Future<List<Guest>> addGuestListToEvent(String eventId, List<Guest> guestList); // Returns the guests with an ID assigned
  Future<Guest> addGuest(String eventId, Guest guest); // Returns guest with Id
  Future<List<Guest>> getGuests(String eventId);
}
