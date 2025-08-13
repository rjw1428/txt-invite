
import 'package:txt_invite/src/models/guest.dart';

abstract class MessagingService {
  Future<void> sendMessage(Guest guest, String message);
}
