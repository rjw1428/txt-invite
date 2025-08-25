
import 'package:txt_invite/src/interfaces/template_service.dart';

import '../interfaces/auth_service.dart';
import '../interfaces/comment_service.dart';
import '../interfaces/event_service.dart';
import '../interfaces/guest_list_service.dart';
import '../interfaces/messaging_service.dart';
import '../interfaces/notification_service.dart';
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
      required this.messaging,
      required this.comments,
      required this.notifications,
      required this.templateService});

  static void initialize(
      AuthService auth,
      EventService events,
      GuestListService guestLists,
      StorageService storage,
      MessagingService messaging,
      CommentService comments,
      NotificationService notifications,
      TemplateService templateService) {
    _instance = Api._(
        auth: auth,
        events: events,
        guestLists: guestLists,
        storage: storage,
        messaging: messaging,
        comments: comments,
        notifications: notifications,
        templateService: templateService);
  }

  final AuthService auth;
  final EventService events;
  final GuestListService guestLists;
  final StorageService storage;
  final MessagingService messaging;
  final CommentService comments;
  final NotificationService notifications;
  final TemplateService templateService;
}
