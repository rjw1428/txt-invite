import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';

abstract class GuestListService {
  Future<void> createGuestList(GuestList guestList);
  Future<List<GuestList>> getGuestLists();
  Future<void> updateGuestList(GuestList guestList);
  Future<void> deleteGuestList(String id);
  Future<List<Guest>> getGuestList(String id);
}