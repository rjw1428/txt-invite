import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  Event? _event;
  Guest? _guest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final event = await Api().events.getEvent(widget.eventId);
      if (event == null) {
        throw Exception('Event not found');
      }
      final guest = await Api().guestLists.getGuest(event.id, widget.guestId);
      if (guest == null) {
        throw Exception('Guest not found');
      }

      final existingRsvp = event.rsvps.firstWhere(
        (rsvp) => rsvp.id == guest.id,
        orElse: () => Rsvp(id: guest.id!, status: RsvpStatus.pending),
      );

      if (existingRsvp.status != RsvpStatus.pending) {
        GoRouter.of(context).go('/events/${widget.eventId}?guestId=${widget.guestId}');
        return;
      }

      setState(() {
        _event = event;
        _guest = guest;
        _selectedStatus = existingRsvp.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('RSVP')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: Text('RSVP')),
        body: Center(child: Text('Error loading details: The event was not found. It may have been canceled. Check with the host')),
      );
    }

    if (_guest == null) {
      return Scaffold(
        appBar: AppBar(title: Text('RSVP')),
        body: Center(child: Text('Error loading details: Your invitation was not found. Check wit hthe host')),
      );
    }

    final event = _event!;
    final guest = _guest!;
    bool hasResponded = event.rsvps.any(
      (rsvp) => rsvp.id == guest.id,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('RSVP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  event.invitationImageUrl,
                  width: 400,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Event: ${event.title}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Guest: ${guest.firstName} ${guest.lastName}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              if (hasResponded)
                Text(
                  'You have already RSVP\'d: ${RsvpStatus.values.firstWhere((status) => status == event.rsvps.firstWhere((rsvp) => rsvp.id == guest.id).status).toString().split('.').last}.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RsvpStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Your RSVP',
                  border: OutlineInputBorder(),
                ),
                items:
                    RsvpStatus.values
                        .where((status) => status != RsvpStatus.pending)
                        .map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.toString().split('.').last,
                            ),
                          );
                        })
                        .toList(),
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
                        const SnackBar(
                          content: Text('RSVP submitted successfully!'),
                        ),
                      );
                      GoRouter.of(
                        context,
                      ).go('/events/${widget.eventId}');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to submit RSVP: $e'),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  hasResponded ? 'Update RSVP' : 'Submit RSVP',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
