import 'package:flutter_background_messenger/flutter_background_messenger.dart';
import 'package:txt_invite/src/interfaces/messaging_service.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/utils/constants.dart';

class SmsService implements MessagingService {
  final messenger = FlutterBackgroundMessenger();

  @override
  Future<bool> sendMessage(Guest guest, Event event) async {
        try {
            return await messenger.sendSMS(
              phoneNumber: guest.phoneNumber,
              message: "$HOST/events/${event.id}/rsvp/${guest.id}"
            );

        } catch (e) {
            print('Error sending SMS: $e');
            return false;
        }
  }
}