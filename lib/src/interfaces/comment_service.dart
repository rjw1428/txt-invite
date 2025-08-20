
import 'package:txt_invite/src/models/comment.dart';

abstract class CommentService {
  Stream<List<Comment>> getComments(String eventId);
  Future<void> addComment(String eventId, Comment comment);
}
