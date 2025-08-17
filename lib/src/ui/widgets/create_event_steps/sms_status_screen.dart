
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/services/api.dart';

enum SmsStatus {
  pending,
  sending,
  sent,
  failed,
}

class SmsStatusScreen extends StatefulWidget {
  final Event event;
  final GuestList guestList;

  const SmsStatusScreen({super.key, required this.event, required this.guestList});

  @override
  State<SmsStatusScreen> createState() => _SmsStatusScreenState();
}

class _SmsStatusScreenState extends State<SmsStatusScreen> {
  final Map<String, SmsStatus> _smsStatus = {};

  @override
  void initState() {
    super.initState();
    for (final guest in widget.guestList.guests) {
      _smsStatus[guest.id!] = SmsStatus.pending;
    }
    _sendSmsMessages();
  }

  Future<void> _sendSmsMessages() async {
    for (final guest in widget.guestList.guests) {
      setState(() {
        _smsStatus[guest.id!] = SmsStatus.sending;
      });
      try {
        final success = await Api().messaging.sendMessage(guest, widget.event);
        setState(() {
          _smsStatus[guest.id!] = success ? SmsStatus.sent : SmsStatus.failed;
        });
      } catch (e) {
        setState(() {
          _smsStatus[guest.id!] = SmsStatus.failed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sending Invitations'),
      ),
      body: ListView.builder(
        itemCount: widget.guestList.guests.length,
        itemBuilder: (context, index) {
          final guest = widget.guestList.guests[index];
          final status = _smsStatus[guest.id!];
          return ListTile(
            title: Text('${guest.firstName} ${guest.lastName}'),
            subtitle: Text(guest.phoneNumber),
            trailing: Icon(
              status == SmsStatus.sent
                  ? Icons.check_circle
                  : status == SmsStatus.failed
                      ? Icons.error
                      : Icons.pending,
              color: status == SmsStatus.sent
                  ? Colors.green
                  : status == SmsStatus.failed
                      ? Colors.red
                      : Colors.grey,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
