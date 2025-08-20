import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';

abstract class GuestListService {
  Future<GuestList> createGuestList(GuestList guestList);
  Future<List<GuestList>> getGuestLists(String uid);
  Future<void> deleteGuestList(String id);
  Future<GuestList?> getGuestList(String eventId);
  Future<Guest?> getGuest(String eventId, String guestId);
  Future<void> deleteGuest(String eventId, Guest guest);
  Future<void> addGuest(String eventId, Guest guest);
  Future<void> updateGuest(String eventId, Guest guest);
}