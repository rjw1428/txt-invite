
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
  final Event? event;
  final GuestList? guestList;

  const SmsStatusScreen({super.key, required this.event, required this.guestList});

  @override
  State<SmsStatusScreen> createState() => _SmsStatusScreenState();
}

class _SmsStatusScreenState extends State<SmsStatusScreen> {
  final Map<String, SmsStatus> _smsStatus = {};
  bool _retry = false;

  @override
  void initState() {
    print('HERE');
    super.initState();
    for (final guest in widget.guestList?.guests ?? []) {
      _smsStatus[guest.id!] = SmsStatus.pending;
    }
    _sendSmsMessages();
  }

  Future<void> _sendSmsMessages() async {
    setState(() => _retry = false);
    for (final guest in widget.guestList?.guests ?? []) {

      if (_smsStatus[guest.id!] == SmsStatus.sent ||
          _smsStatus[guest.id!] == SmsStatus.sending) {
        continue; // Skip already sent or sending guests
      }
      
      setState(() {
        _smsStatus[guest.id!] = SmsStatus.sending;
      });
      try {
        final success = await Api().messaging.sendMessage(guest, widget.event!);
        if (!success) {
          setState(() {
            _retry = true;
            _smsStatus[guest.id!] = SmsStatus.failed;
          });
        } else {
          setState(() {
            _smsStatus[guest.id!] = SmsStatus.sent;
          });
        }
        await Future.delayed(const Duration(milliseconds: 500)); // Delay to let messages send
      } catch (e) {
        setState(() {
          _retry = true;
          _smsStatus[guest.id!] = SmsStatus.failed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListView.builder(
            itemCount: widget.guestList?.guests.length ?? 0,
            itemBuilder: (context, index) {
              final guest = widget.guestList?.guests[index];
              final status = _smsStatus[guest?.id!];
              return ListTile(
                title: Text('${guest?.firstName} ${guest?.lastName}'),
                subtitle: Text(guest?.phoneNumber ?? ''),
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
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     Navigator.of(context).popUntil((route) => route.isFirst);
            //   },
            //   child: const Icon(Icons.done),
            // ),
          ),
          if (_retry)
            ElevatedButton(
              onPressed: _sendSmsMessages,
              child: const Text('Retry Failed Messages'),
            ),
        ],
      ),
    );
  }
}
