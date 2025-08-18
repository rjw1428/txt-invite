import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/guest_list_service.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:uuid/uuid.dart';

class FirebaseGuestListService implements GuestListService {

  final FirebaseFirestore _firestore;

  FirebaseGuestListService._internal()
      : _firestore = FirebaseFirestore.instance;

  FirebaseGuestListService() : this._internal();


  @override
  Future<GuestList> createGuestList(GuestList guestList) async {
    final doc = _firestore.collection('guest_lists').doc();
    final newGuestList = guestList.copyWith(id: doc.id);
    await doc.set(newGuestList.toJson());
    return newGuestList;
  }

  @override
  Future<void> deleteGuestList(String guestListId) async {
    await _firestore.collection('guest_lists').doc(guestListId).delete();
  }

  @override
  Future<GuestList?> getGuestList(String guestListId) async {
    final doc = await _firestore.collection('guest_lists').doc(guestListId).get();
    if (doc.exists) {
      return GuestList.fromMap({'id': doc.id, ...doc.data()!});
    }
    return null;
  }

  @override
  Future<List<GuestList>> getGuestLists(String uid) async {
    final snapshot = await _firestore.collection('guest_lists').where('createdBy', isEqualTo: uid).get();

    if (snapshot.docs.isEmpty) {
      return [];
    }
    
    return snapshot.docs.map((doc) => GuestList.fromMap({'id': doc.id, ...doc.data()})).toList();
  }

  @override
  Future<Guest?> getGuest(String guestListId, String guestId) async {
    final doc = await _firestore.collection('guest_lists').doc(guestListId).get();
    if (!doc.exists) {
      return null;
    }

    final guestList = GuestList.fromMap(doc.data()!);
    try {
      return guestList.guests.firstWhere((guest) => guest.id == guestId);
    } catch (e) {
      return null;
    }
    
  }

  @override
  Future<void> deleteGuest(String guestListId, Guest guest) async {
    final docRef = _firestore.collection('guest_lists').doc(guestListId);
    await docRef.update({
      'guests': FieldValue.arrayRemove([guest.toJson()])
    });
  }

  @override
  Future<void> addGuest(String guestListId, Guest guest) async {
    final docRef = _firestore.collection('guest_lists').doc(guestListId);
    final newGuest = guest.copyWith(id: const Uuid().v4());
    await docRef.update({
      'guests': FieldValue.arrayUnion([newGuest.toJson()])
    });
  }

  @override
  Future<void> updateGuest(String guestListId, Guest guest) async {
    final docRef = _firestore.collection('guest_lists').doc(guestListId);
    final guestListSnapshot = await docRef.get();

    if (guestListSnapshot.exists) {
      final guestList = GuestList.fromMap(guestListSnapshot.data()!);
      final updatedGuests = guestList.guests.map((g) {
        return g.id == guest.id ? guest : g;
      }).toList();

      await docRef.update({
        'guests': updatedGuests.map((g) => g.toJson()).toList()
      });
    }
  }
}