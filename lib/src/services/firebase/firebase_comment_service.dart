
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txt_invite/src/interfaces/comment_service.dart';
import 'package:txt_invite/src/models/comment.dart';

class FirebaseCommentService implements CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Comment>> getComments(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addComment(String eventId, Comment comment) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .add(comment.toFirestore());
  }
}
