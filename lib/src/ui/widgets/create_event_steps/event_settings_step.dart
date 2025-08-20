
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event_settings.dart';

class EventSettingsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final EventSettings settings;
  final ValueChanged<EventSettings> onSettingsChanged;

  const EventSettingsStep({
    super.key,
    required this.formKey,
    required this.settings,
    required this.onSettingsChanged,
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
            value: widget.settings.allowComments,
            onChanged: (value) => widget.onSettingsChanged(widget.settings.copyWith(allowComments: value)),
          ),
          SwitchListTile(
            title: const Text('Guest List Visible to Guests'),
            value: widget.settings.guestListVisible,
            onChanged: (value) => widget.onSettingsChanged(widget.settings.copyWith(guestListVisible: value)),
          ),
          SwitchListTile(
            title: const Text('RSVP Required'),
            value: widget.settings.rsvpRequired,
            onChanged: (value) => widget.onSettingsChanged(widget.settings.copyWith(rsvpRequired: value)),
          ),
          SwitchListTile(
            title: const Text('Generate QR Code'),
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
      )
    );
  }
}
