import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/rsvp.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/widgets/cancel_event_dialog.dart';
import 'package:txt_invite/src/ui/widgets/guest_list_detail_dialog.dart';

import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/utils/constants.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final bool showActionMenu;
  const EventCard({super.key, required this.event, this.showActionMenu = true});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  Widget actionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'add_guest') {
          final guestList = await Api().guestLists.getGuestList(
            widget.event.guestListId,
          );
          if (guestList != null) {
            showDialog(
              context: context,
              builder:
                  (context) => GuestListDetailDialog(
                    guestList: guestList,
                    onDeleteGuest: (Guest guest) async {
                      await Api().guestLists.deleteGuest(
                        widget.event.guestListId,
                        guest,
                      );
                    },
                    onSaveGuest: (Guest guest) async {
                      if (guest.id != null) {
                        await Api().guestLists.updateGuest(
                          widget.event.guestListId,
                          guest,
                        );
                      } else {
                        await Api().guestLists.addGuest(
                          widget.event.guestListId,
                          guest,
                        );
                      }
                    },
                  ),
            );
          }
        } else if (value == 'cancel_event') {
          showDialog(
            context: context,
            builder:
                (context) => CancelEventDialog(
                  onConfirm: (reason) async {
                    await Api().events.cancelEvent(widget.event.id);
                    final guestList = await Api().guestLists.getGuestList(
                      widget.event.guestListId,
                    );
                    if (guestList != null) {
                      for (final guest in guestList.guests) {
                        await Api().messaging.sendCancellationMessage(
                          guest,
                          widget.event,
                          reason,
                        );
                      }
                    }
                  },
                ),
          );
        // For Debugging
        } else if (value == 'delete_event') {
          await Api().events.deleteEvent(widget.event.id);
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'add_guest',
              child: Text('Add Guest'),
            ),
            const PopupMenuItem<String>(
              value: 'cancel_event',
              child: Text('Cancel Event'),
            ),
            const PopupMenuItem<String>(
              value: 'delete_event',
              child: Text('Delete Event'),
            ),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/events/${widget.event.id}', extra: {'fromHome': true});
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.showActionMenu)
                actionMenu(context),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(widget.event.description),
              const SizedBox(height: 8),
              Text(
                'Starts: ${dateTimeFormat.format(widget.event.startTime.toLocal())}',
              ),
              Text(
                'Ends: ${dateTimeFormat.format(widget.event.endTime.toLocal())}',
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attending: ${widget.event.rsvpCounts[RsvpStatus.attending] ?? 0}',
                  ),
                  Text(
                    'Maybe: ${widget.event.rsvpCounts[RsvpStatus.maybe] ?? 0}',
                  ),
                  Text(
                    'Not Attending: ${widget.event.rsvpCounts[RsvpStatus.notAttending] ?? 0}',
                  ),
                  Text(
                    'Pending: ${widget.event.rsvpCounts[RsvpStatus.pending] ?? 0}',
                  ),
                ],
              ),
              if (widget.event.status == EventStatus.cancelled) ...[
                const SizedBox(height: 8),
                Center(
                  child: const Text(
                    'Event has been cancelled',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
