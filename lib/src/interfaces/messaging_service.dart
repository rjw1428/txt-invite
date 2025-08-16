
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';

abstract class MessagingService {
  Future<bool> sendMessage(Guest guest, Event event);
}
