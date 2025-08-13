import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/guest_list_service.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';

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
  Future<List<Guest>> getGuestList(String guestListId) async {
    final doc = await _firestore.collection('guest_lists').doc(guestListId).get();
    if (doc.exists) {
      return GuestList.fromMap(doc.data()!).guests;
    }
    return [];
  }

  @override
  Future<List<GuestList>> getGuestLists() async {
    final snapshot = await _firestore.collection('guest_lists').get();
    return snapshot.docs.map((doc) => GuestList.fromMap({'id': doc.id, ...doc.data()})).toList();
  }

  @override
  Future<void> updateGuestList(GuestList guestList) async {
    await _firestore.collection('guest_lists').doc(guestList.id).update(guestList.toJson());
  }
}