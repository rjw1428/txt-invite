import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/template_service.dart';
import 'package:txt_invite/src/models/invitation.dart';

class FirebaseTemplateService implements TemplateService {
  final FirebaseFirestore _firestore;

  FirebaseTemplateService._internal() : _firestore = FirebaseFirestore.instance;

  FirebaseTemplateService() : this._internal();

  @override
  Future<List<Invitation>> getAllTemplates() async {
    final snapshot = await _firestore.collection('templates').get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    

    return snapshot.docs
        .map((doc) => Invitation.fromJson(doc.data()))
        .toList();
  }

}