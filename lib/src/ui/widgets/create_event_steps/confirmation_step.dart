
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event_settings.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart'; // Import GuestList
import 'package:txt_invite/src/services/api.dart';

class ConfirmationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? selectedTemplate;
  final EventSettings settings;
  final List<Guest> guestList;

  const ConfirmationStep({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.selectedTemplate,
    required this.settings,
    required this.guestList,
  });

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  final TextEditingController _guestListNameController = TextEditingController();

  @override
  void dispose() {
    _guestListNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey, // Use widget.formKey
        child: ListView(
          children: [
            const Text(
              'Confirm Event Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Title: ${widget.title}'), // Use widget.title
            Text('Description: ${widget.description}'), // Use widget.description
            Text('Start Time: ${widget.startTime?.toLocal().toString().split('.')[0] ?? 'N/A'}'), // Use widget.startTime
            Text('End Time: ${widget.endTime?.toLocal().toString().split('.')[0] ?? 'N/A'}'), // Use widget.endTime
            Text('Selected Template: ${widget.selectedTemplate ?? 'N/A'}'), // Use widget.selectedTemplate
            Text('Allow Comments: ${widget.settings.allowComments ? 'Yes' : 'No'}'), // Use widget.settings
            Text('Guest List Visible: ${widget.settings.guestListVisible ? 'Yes' : 'No'}'), // Use widget.settings
            Text('RSVP Required: ${widget.settings.rsvpRequired ? 'Yes' : 'No'}'), // Use widget.settings
            const SizedBox(height: 16),
            const Text(
              'Guest List:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.guestList.map((guest) => Text("${guest.firstName} ${guest.lastName}")), // Use widget.guestList
            const SizedBox(height: 16), // Add some space before the button
            ElevatedButton(
              onPressed: () => _showSaveGuestListDialog(context),
              child: const Text('Save Guest List for Later'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveGuestListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Guest List'),
          content: TextField(
            controller: _guestListNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Guest List Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_guestListNameController.text.isNotEmpty) {
                  final newGuestList = GuestList(
                    name: _guestListNameController.text,
                    guests: widget.guestList,
                    createdBy: Api().auth.currentUser!.id,
                    createdAt: DateTime.now(),
                  );
                  try {
                    await Api().guestLists.createGuestList(newGuestList);
                    // Optionally show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guest list saved successfully!')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Optionally show an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save guest list: $e')),
                    );
                  }
                } else {
                  // Show a message if the name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guest list name cannot be empty.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
