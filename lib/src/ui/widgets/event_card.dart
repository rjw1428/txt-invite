import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/rsvp.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/screens/add_edit_guest_screen.dart';
import 'package:txt_invite/src/ui/widgets/cancel_event_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/utils/constants.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final bool showActionMenu;
  // final VoidCallback onUpdate;

  const EventCard({super.key, required this.event, this.showActionMenu = true});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late Event event;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  Widget actionMenu(BuildContext contesxt) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'add_guest') {
          final guestList = await Api().events.getGuests(event.id);
          if (guestList.isNotEmpty) {
            final newGuest = await showDialog<Guest>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: AddEditGuestScreen(
                    onSave: (guest) async {
                      // This onSave is for the single guest, not the list
                    },
                  ),
                );
              },
            );
            if (newGuest != null) {
              final existingGuest = guestList.firstWhere(
                (g) => g.phoneNumber == newGuest.phoneNumber,
                orElse: () => Guest(id: '', phoneNumber: ''),
              );
              if (existingGuest.id!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Guest with phone number ${newGuest.phoneNumber} already exists.',
                    ),
                  ),
                );
                return;
              }
              final guestWithId = await Api().events.addGuest(
                event.id,
                newGuest,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sending invitation to ${guestWithId.firstName} ${guestWithId.lastName}!',
                  ),
                ),
              );
              final success = await Api().messaging.sendMessage(
                guestWithId,
                event,
              );
              final statusMessage =
                  success
                      ? 'Invitation delivered to ${guestWithId.firstName} ${guestWithId.lastName}'
                      : 'Error: Invitation to ${guestWithId.firstName} ${guestWithId.lastName} failed to send.';
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(statusMessage)));
              // onUpdate();
              setState(() {
                event = event.copyWith(
                  guestList: [...event.guestList, guestWithId],
                  inviteCount: event.inviteCount + 1,
                );
              });
            }
          }
        } else if (value == 'cancel_event') {
          showDialog(
            context: context,
            builder:
                (context) => CancelEventDialog(
                  onConfirm: (reason) async {
                    await Api().events.cancelEvent(event.id);
                    final guestList = await Api().guestLists.getGuestList(
                      event.id,
                    );
                    if (guestList != null) {
                      for (final guest in guestList.guests) {
                        await Api().messaging.sendCancellationMessage(
                          guest,
                          event,
                          reason,
                        );
                      }
                    }
                  },
                ),
          );
          // For Debugging
        } else if (value == 'delete_event') {
          await Api().events.deleteEvent(event.id);
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
    print('Building EventCard for event: ${event.rsvpCounts} guests');
    return InkWell(
      onTap: () {
        context.go('/events/${event.id}', extra: {'fromHome': true});
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.showActionMenu) actionMenu(context),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.invitationImageThumbnailUrl != 'nothing')
                Image.network(
                  event.invitationImageThumbnailUrl,
                  width: 300,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 8),
              Text(
                'Starts: ${dateTimeFormat.format(event.startTime.toLocal())}',
              ),
              Text('Ends: ${dateTimeFormat.format(event.endTime.toLocal())}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attending: ${event.rsvpCounts[RsvpStatus.attending] ?? 0}',
                  ),
                  Text('Maybe: ${event.rsvpCounts[RsvpStatus.maybe] ?? 0}'),
                  Text(
                    'Not Attending: ${event.rsvpCounts[RsvpStatus.notAttending] ?? 0}',
                  ),
                  Text('Pending: ${event.rsvpCounts[RsvpStatus.pending] ?? 0}'),
                ],
              ),
              if (event.status == EventStatus.cancelled) ...[
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
