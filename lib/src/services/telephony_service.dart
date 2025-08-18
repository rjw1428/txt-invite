
import 'dart:async';
import 'package:another_telephony/telephony.dart';
import 'package:txt_invite/src/interfaces/messaging_service.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/utils/constants.dart';


const MESSAGE_TIMEOUT = Duration(seconds: 10);

class TelephonyService implements MessagingService {
  final messenger = Telephony.instance;

  @override
  Future<bool> sendMessage(Guest guest, Event event) async {
    final Completer<bool> completer = Completer<bool>();

    try {
      await messenger.sendSms(
        to: guest.phoneNumber,
        message: "You are invited to the following event: $HOST/rsvp?eventId=${event.id}&guestId=${guest.id}",
        statusListener: (SendStatus status) {
          if (status == SendStatus.DELIVERED) {
            print('SMS delivered');
            completer.complete(true);
          } else if (status == SendStatus.SENT) {
            print('SMS sent successfully');
          }
        }
      );
    } catch (e) {
        print('Error sending SMS: $e');
        completer.complete(false);
    }
    return completer.future.timeout(MESSAGE_TIMEOUT, onTimeout: () {
      print('SMS timeout');
      return false;
    });
  }

  @override
  Future<bool> sendCancellationMessage(Guest guest, Event event, String reason) async {
    try {
      await messenger.sendSms(
        to: guest.phoneNumber,
        message: "${event.title} has been cancelled: $reason"
      );
      return true;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
}