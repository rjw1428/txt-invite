
import '../interfaces/auth_service.dart';
import '../interfaces/event_service.dart';
import '../interfaces/guest_list_service.dart';
import '../interfaces/messaging_service.dart';
import '../interfaces/storage_service.dart';

class Api {
  static late final Api _instance;

  factory Api() {
    return _instance;
  }

  Api._(
      {required this.auth,
      required this.events,
      required this.guestLists,
      required this.storage,
      required this.messaging});

  static void initialize(
      AuthService auth,
      EventService events,
      GuestListService guestLists,
      StorageService storage,
      MessagingService messaging) {
    _instance = Api._(
        auth: auth,
        events: events,
        guestLists: guestLists,
        storage: storage,
        messaging: messaging);
  }

  final AuthService auth;
  final EventService events;
  final GuestListService guestLists;
  final StorageService storage;
  final MessagingService messaging;
}
