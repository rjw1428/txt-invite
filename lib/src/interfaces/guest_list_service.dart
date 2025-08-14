import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';

abstract class GuestListService {
  Future<void> createGuestList(GuestList guestList);
  Future<List<GuestList>> getGuestLists(String uid);
  Future<void> deleteGuestList(String id);
  Future<List<Guest>> getGuestList(String id);
  Future<Guest?> getGuest(String guestListId, String guestId);
  Future<void> deleteGuest(String guestListId, Guest guest);
  Future<void> addGuest(String guestListId, Guest guest);
  Future<void> updateGuest(String guestListId, Guest guest);
}