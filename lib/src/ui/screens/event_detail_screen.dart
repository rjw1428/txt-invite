import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/models/comment.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/rsvp.dart';
import 'package:txt_invite/src/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2calendar;
import 'package:txt_invite/src/services/api.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final String? guestId;

  const EventDetailScreen({super.key, required this.eventId, this.guestId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<Event> _eventFuture;
  late Future<List<Guest>> _guestListFuture;
  final _commentController = TextEditingController();

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
    _guestListFuture = Api().events.getGuests(event.id).then((guestList) async {
      if (event.settings.rsvpRequired) {
        final rsvps = await Api().events.getRsvps(event.id);
        final rsvpMap = {for (var rsvp in rsvps) rsvp.id: rsvp};
        for (var guest in guestList) {
          guest = guest.withRsvp(
            rsvpMap[guest.id] ??
                Rsvp(id: guest.id!, status: RsvpStatus.pending),
          );
        }
      }
      return guestList;
    });

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

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      String author = 'Event Host'; //Api().auth.currentUser?.displayName ??
      if (widget.guestId != null) {
        final guestList = await _guestListFuture;
        if (guestList.isNotEmpty) {
          final guest = guestList.firstWhere((g) => g.id == widget.guestId);
          author = '${guest.firstName} ${guest.lastName}';
        }
      }
      final comment = Comment(
        id: '', // Firestore will generate the ID
        text: _commentController.text,
        author: author,
        createdAt: Timestamp.now(),
      );
      await Api().comments.addComment(widget.eventId, comment);
      _commentController.clear();
    }
  }

  Future<void> _showRsvpConfirmationDialog(RsvpStatus newStatus) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm RSVP'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to change your RSVP to ${_getRsvpStatusString(newStatus)}?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                await Api().events.updateRsvp(
                  eventId: widget.eventId,
                  guestId: widget.guestId!,
                  status: newStatus,
                );
                setState(() {
                  _eventFuture = _fetchEvent();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading:
            (GoRouterState.of(context).extra is Map &&
                    (GoRouterState.of(context).extra as Map)['fromHome'] ==
                        true)
                ? BackButton(
                  onPressed: () {
                    GoRouter.of(context).go('/dashboard');
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
                      event.invitationBackground,
                      width: 800,
                      height: 600,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (event.location != null)
                            SelectableLinkify(
                              text: 'Location: ${event.location}',
                              onOpen: (link) async {
                                if (await canLaunchUrl(Uri.parse(link.url))) {
                                  await launchUrl(Uri.parse(link.url));
                                } else {
                                  print('Could not launch ${link.url}');
                                }
                              },
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              linkStyle: const TextStyle(color: Colors.blue),
                            ),
                          const SizedBox(height: 8),
                          SelectableLinkify(
                            onOpen: (link) async {
                              if (await canLaunchUrl(Uri.parse(link.url))) {
                                await launchUrl(Uri.parse(link.url));
                              } else {
                                print('Could not launch ${link.url}');
                              }
                            },
                            text: event.description,
                            style: const TextStyle(fontSize: 16),
                            linkStyle: const TextStyle(color: Colors.blue),
                          ),
                          const SizedBox(height: 16),
                          SelectableText(
                            'Starts: ${dateTimeFormat.format(event.startTime.toLocal())}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          SelectableText(
                            'Ends: ${dateTimeFormat.format(event.endTime.toLocal())}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          if (!kIsWeb)
                            ElevatedButton(
                              onPressed: () {
                                final calEvent = add2calendar.Event(
                                  title: event.title,
                                  description: event.description,
                                  location: event.location ?? '',
                                  startDate: event.startTime,
                                  endDate: event.endTime,
                                );
                                add2calendar.Add2Calendar.addEvent2Cal(
                                  calEvent,
                                );
                              },
                              child: const Text('Add to Calendar'),
                            ),
                          const SizedBox(height: 16),
                          if (event.qrCodeImageUrl != null) ...[
                            const Text(
                              'QR Code:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Image.network(
                              event.qrCodeImageUrl!,
                              width: 200,
                              height: 200,
                            ),
                            if (Api().auth.currentUser != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final uri = Uri.parse(
                                      event.qrCodeImageUrl!,
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      throw 'Could not launch $uri';
                                    }
                                  },
                                  child: const Text('Download'),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                          if (event.settings.guestListVisible) ...[
                            const Text(
                              'Guests:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            FutureBuilder<List<Guest>>(
                              future: _guestListFuture,
                              builder: (context, guestListSnapshot) {
                                if (guestListSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (guestListSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${guestListSnapshot.error}',
                                    ),
                                  );
                                } else if (!guestListSnapshot.hasData ||
                                    guestListSnapshot.data!.isEmpty) {
                                  return const Text('No guests invited.');
                                } else {
                                  final guestList = guestListSnapshot.data!;
                                  return event.settings.rsvpRequired
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            guestList.map((guest) {
                                              if (guest.id == widget.guestId) {
                                                return Row(
                                                  children: [
                                                    Text(
                                                      '- ${guest.firstName} ${guest.lastName}',
                                                    ),
                                                    const SizedBox(width: 8),
                                                    DropdownButton<RsvpStatus>(
                                                      value: guest.rsvp!.status,
                                                      onChanged: (newStatus) {
                                                        if (newStatus != null) {
                                                          _showRsvpConfirmationDialog(
                                                            newStatus,
                                                          );
                                                        }
                                                      },
                                                      items:
                                                          RsvpStatus.values
                                                              .map(
                                                                (
                                                                  status,
                                                                ) => DropdownMenuItem(
                                                                  value: status,
                                                                  child: Text(
                                                                    _getRsvpStatusString(
                                                                      status,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Text(
                                                  '- ${guest.firstName} ${guest.lastName} (${_getRsvpStatusString(guest.rsvp!.status)})',
                                                );
                                              }
                                            }).toList(),
                                      )
                                      : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            guestList.map((guest) {
                                              return Text(
                                                '- ${guest.firstName} ${guest.lastName}',
                                              );
                                            }).toList(),
                                      );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (event.settings.allowComments) ...[
                            const Text(
                              'Comments:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            StreamBuilder<List<Comment>>(
                              stream: Api().comments.getComments(
                                widget.eventId,
                              ),
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (commentSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${commentSnapshot.error}',
                                    ),
                                  );
                                } else if (!commentSnapshot.hasData ||
                                    commentSnapshot.data!.isEmpty) {
                                  return const Text('No comments yet.');
                                } else {
                                  final comments = commentSnapshot.data!;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = comments[index];
                                      return Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${comment.author} - ",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                Text(
                                                  dateTimeFormat.format(
                                                    comment.createdAt.toDate(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              comment.text,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      labelText: 'Add a comment',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _addComment,
                                ),
                              ],
                            ),
                          ],
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
