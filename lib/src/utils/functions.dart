import 'package:qr_flutter/qr_flutter.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/utils/constants.dart';

Function tryCatch = (Function fn, Function? onError) async {
  try {
    await fn();
  } catch (e) {
    print('Error: $e');
    if (onError != null) {
      return onError(e);
    }
    return null;
  }
};

Future<String> generateQrCode(Event event) async {
  final anonymousGuest = Guest(firstName: ANONYMOUS_GUEST_NAME, lastName: '', phoneNumber: '');
  final addedGuest = await Api().events.addGuest(event.id, anonymousGuest);

  final qrPainter = QrPainter(
    data: 'https://txt-invitation.web.app/events/${event.id}?guestId=${addedGuest.id}',
    version: QrVersions.auto,
    gapless: false,
  );

  final picData = await qrPainter.toImageData(200);
  final qrBytes = picData!.buffer.asUint8List();
  final qrCodeImageUrl = await Api().storage.uploadBytes(
    qrBytes,
    'qrcodes/${event.id}_qr.png',
  );
  return qrCodeImageUrl;
}