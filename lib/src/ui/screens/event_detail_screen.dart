
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/models/rsvp.dart';

import 'package:txt_invite/src/services/api.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<Event> _eventFuture;
  late Future<GuestList?> _guestListFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = _fetchEvent();
  }

  Future<Event> _fetchEvent() async {
    final event = await Api().events.getEvent(widget.eventId);
    if (event == null) {
      throw Exception('Event not found');
    }
    _guestListFuture = Api().guestLists.getGuestList(event.guestListId);
    return event;
  }

  String _getRsvpStatusString(RsvpStatus status) {
    switch (status) {
      case RsvpStatus.attending:
        return 'Attending';
      case RsvpStatus.notAttending:
        return 'Not Attending';
      case RsvpStatus.maybe:
        return 'Maybe';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: (GoRouterState.of(context).extra is Map && (GoRouterState.of(context).extra as Map)['fromHome'] == true)
            ? BackButton(
                onPressed: () {
                  GoRouter.of(context).go('/');
                },
              )
            : null,
      ),
      body: FutureBuilder<Event>(
        future: _eventFuture,
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (eventSnapshot.hasError) {
            return Center(child: Text('Error: ${eventSnapshot.error}'));
          } else if (!eventSnapshot.hasData) {
            return const Center(child: Text('Event not found.'));
          } else {
            final event = eventSnapshot.data!;
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      event.invitationImageUrl,
                      width: 800,
                      height: 600,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Starts: ${event.startTime.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Ends: ${event.endTime.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Guests:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<GuestList?>(
                            future: _guestListFuture,
                            builder: (context, guestListSnapshot) {
                              if (guestListSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (guestListSnapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${guestListSnapshot.error}'));
                              } else if (!guestListSnapshot.hasData ||
                                  guestListSnapshot.data!.guests.isEmpty) {
                                return const Text('No guests invited.');
                              } else {
                                final guestList = guestListSnapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: guestList.guests.map((guest) {
                                    final rsvp = event.rsvps.firstWhere(
                                      (r) => r.id == guest.id,
                                      orElse: () => Rsvp(id: guest.id!, status: RsvpStatus.pending), // Default to pending if no RSVP found
                                    );
                                    return Text(
                                        '- ${guest.firstName} ${guest.lastName} (${_getRsvpStatusString(rsvp.status)})');
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
