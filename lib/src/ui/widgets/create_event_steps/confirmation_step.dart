
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event_settings.dart';

class ConfirmationStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? selectedTemplate;
  final String? selectedGuestListId;
  final EventSettings settings;

  const ConfirmationStep({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.selectedTemplate,
    required this.selectedGuestListId,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            const Text(
              'Confirm Event Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Title: $title'),
            Text('Description: $description'),
            Text('Start Time: ${startTime?.toLocal().toString().split('.')[0] ?? 'N/A'}'),
            Text('End Time: ${endTime?.toLocal().toString().split('.')[0] ?? 'N/A'}'),
            Text('Selected Template: ${selectedTemplate ?? 'N/A'}'),
            Text('Selected Guest List ID: ${selectedGuestListId ?? 'N/A'}'),
            Text('Allow Comments: ${settings.allowComments ? 'Yes' : 'No'}'),
            Text('Guest List Visible: ${settings.guestListVisible ? 'Yes' : 'No'}'),
            Text('RSVP Required: ${settings.rsvpRequired ? 'Yes' : 'No'}'),
          ],
        ),
      ),
    );
  }
}
