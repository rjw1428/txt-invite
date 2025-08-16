
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/rsvp.dart';

import 'package:go_router/go_router.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/events/${event.id}', extra: {'fromHome': true});
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 8),
              Text(
                'Starts: ${event.startTime.toLocal().toString().split('.')[0]}',
              ),
              Text(
                'Ends: ${event.endTime.toLocal().toString().split('.')[0]}',
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Attending: ${event.rsvpCounts[RsvpStatus.attending] ?? 0}'),
                  Text('Maybe: ${event.rsvpCounts[RsvpStatus.maybe] ?? 0}'),
                  Text('Not Attending: ${event.rsvpCounts[RsvpStatus.notAttending] ?? 0}'),
                  Text('Pending: ${event.rsvpCounts[RsvpStatus.pending] ?? 0}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
