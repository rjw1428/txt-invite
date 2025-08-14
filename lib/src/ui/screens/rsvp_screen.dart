
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/rsvp.dart';

import 'package:txt_invite/src/services/api.dart';

class RsvpScreen extends StatefulWidget {
  final String eventId;
  final String guestId;

  const RsvpScreen({super.key, required this.eventId, required this.guestId});

  @override
  State<RsvpScreen> createState() => _RsvpScreenState();
}

class _RsvpScreenState extends State<RsvpScreen> {
  final _formKey = GlobalKey<FormState>();
  RsvpStatus? _selectedStatus;
  late Future<Event?> _eventFuture;
  late Function(Event)  _guestFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = Api().events.getEvent(widget.eventId);
    _guestFuture = (Event event) => Api().guestLists.getGuest(event.guestListId, widget.guestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSVP'),
      ),
      body: FutureBuilder(
        future: _eventFuture,
        builder: (context, AsyncSnapshot<Event?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error loading details'));
          }

          final event = snapshot.data!;

          return FutureBuilder(
            future: _guestFuture(snapshot.data!),
            builder: (context, AsyncSnapshot<Guest?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Error loading guest details'));
              }

              final guest = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event: ${event.title}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Guest: ${guest.firstName} ${guest.lastName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RsvpStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Your RSVP',
                      border: OutlineInputBorder(),
                    ),
                    items: RsvpStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an RSVP status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await Api().events.updateRsvp(
                                eventId: widget.eventId,
                                guestId: widget.guestId,
                                status: _selectedStatus!,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('RSVP submitted successfully!')),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit RSVP: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Submit RSVP'),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ));
  }
}
