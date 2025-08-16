
import 'package:flutter/material.dart';

class EventSettingsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool allowComments;
  final bool guestListVisible;
  final bool rsvpRequired;
  final ValueChanged<bool> onAllowCommentsChanged;
  final ValueChanged<bool> onGuestListVisibleChanged;
  final ValueChanged<bool> onRsvpRequiredChanged;

  const EventSettingsStep({
    super.key,
    required this.formKey,
    required this.allowComments,
    required this.guestListVisible,
    required this.rsvpRequired,
    required this.onAllowCommentsChanged,
    required this.onGuestListVisibleChanged,
    required this.onRsvpRequiredChanged,
  });

  @override
  State<EventSettingsStep> createState() => _EventSettingsStepState();
}

class _EventSettingsStepState extends State<EventSettingsStep> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Allow Comments from Guests'),
            value: widget.allowComments,
            onChanged: widget.onAllowCommentsChanged,
          ),
          SwitchListTile(
            title: const Text('Guest List Visible to Guests'),
            value: widget.guestListVisible,
            onChanged: widget.onGuestListVisibleChanged,
          ),
          SwitchListTile(
            title: const Text('RSVP Required'),
            value: widget.rsvpRequired,
            onChanged: widget.onRsvpRequiredChanged,
          ),
        ],
      ),
      )
    );
  }
}
