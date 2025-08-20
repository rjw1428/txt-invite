import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/models/comment.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/models/rsvp.dart';

import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/utils/constants.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final String? guestId;

  const EventDetailScreen({super.key, required this.eventId, this.guestId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<Event> _eventFuture;
  late Future<GuestList?> _guestListFuture;
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

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      String author = 'Anonymous';
      if (widget.guestId != null) {
        final guestList = await _guestListFuture;
        if (guestList != null) {
          final guest = guestList.guests.firstWhere((g) => g.id == widget.guestId);
          author = '${guest.firstName} ${guest.lastName}';
        }
      } else {
        author = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';
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
                Text('Are you sure you want to change your RSVP to ${_getRsvpStatusString(newStatus)}?'),
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
              onPressed: () {
                Api().events.updateRsvp(
                  eventId: widget.eventId,
                  guestId: widget.guestId!,
                  status: newStatus,
                );
                Navigator.of(context).pop();
                setState(() {
                  _eventFuture = _fetchEvent();
                });
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
                            'Starts: ${dateTimeFormat.format(event.startTime.toLocal())}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Ends: ${dateTimeFormat.format(event.endTime.toLocal())}',
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
                                  child: CircularProgressIndicator(),
                                );
                              } else if (guestListSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error: ${guestListSnapshot.error}',
                                  ),
                                );
                              } else if (!guestListSnapshot.hasData ||
                                  guestListSnapshot.data!.guests.isEmpty) {
                                return const Text('No guests invited.');
                              } else {
                                final guestList = guestListSnapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      guestList.guests.map((guest) {
                                        final rsvp = event.rsvps.firstWhere(
                                          (r) => r.id == guest.id,
                                          orElse:
                                              () => Rsvp(
                                                id: guest.id!,
                                                status: RsvpStatus.pending,
                                              ), // Default to pending if no RSVP found
                                        );
                                        if (guest.id == widget.guestId) {
                                          return Row(
                                            children: [
                                              Text(
                                                '- ${guest.firstName} ${guest.lastName}',
                                              ),
                                              const SizedBox(width: 8),
                                              DropdownButton<RsvpStatus>(
                                                value: rsvp.status,
                                                onChanged: (newStatus) {
                                                  if (newStatus != null) {
                                                    _showRsvpConfirmationDialog(newStatus);
                                                  }
                                                },
                                                items: RsvpStatus.values
                                                    .map((status) => DropdownMenuItem(
                                                          value: status,
                                                          child: Text(_getRsvpStatusString(status)),
                                                        ))
                                                    .toList(),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Text(
                                            '- ${guest.firstName} ${guest.lastName} (${_getRsvpStatusString(rsvp.status)})',
                                          );
                                        }
                                      }).toList(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Comments:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StreamBuilder<List<Comment>>(
                            stream: Api().comments.getComments(widget.eventId),
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
                                    return ListTile(
                                      title: Text(comment.author),
                                      subtitle: Text(comment.text),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              labelText: 'Add a comment',
                            ),
                          ),
                          TextButton(
                            onPressed: _addComment,
                            child: const Text('Add Comment'),
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
