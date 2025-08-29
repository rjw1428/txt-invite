import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:txt_invite/src/models/event_settings.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final EventSettings settings;
  final List<Guest> guestList;
  final Uint8List? invitationImage;
  final String? location;

  const ConfirmationStep({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.settings,
    required this.guestList,
    required this.invitationImage,
    this.location,
  });

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  final TextEditingController _guestListNameController =
      TextEditingController();

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
        key: widget.formKey,
        child: ListView(
          children: [
            const Text(
              'Confirm Event Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (widget.invitationImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.memory(
                  widget.invitationImage!,
                  width: 400,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            SelectableText(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              text: widget.description,
              style: const TextStyle(fontSize: 16),
              linkStyle: const TextStyle(color: Colors.blue),
            ),
            if (widget.location != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child:                          
                            SelectableLinkify(
                              text: 'Location: ${widget.location}',
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
              ),
            const SizedBox(height: 16),
            SelectableText(
              'Starts: ${dateTimeFormat.format(widget.startTime!.toLocal())}',
              style: const TextStyle(fontSize: 14),
            ),
            SelectableText(
              'Ends: ${dateTimeFormat.format(widget.endTime!.toLocal())}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Allow Comments: ${widget.settings.allowComments ? 'Yes' : 'No'}',
            ),
            Text(
              'Guest List Visible: ${widget.settings.guestListVisible ? 'Yes' : 'No'}',
            ),
            Text(
              'RSVP Required: ${widget.settings.rsvpRequired ? 'Yes' : 'No'}',
            ),
            Text(
              'Generate QR Code: ${widget.settings.qrCodeEnabled ? 'Yes' : 'No'}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Guest List:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.guestList.map(
              (guest) => Text("${guest.firstName} ${guest.lastName}"),
            ), 
            const SizedBox(height: 16),
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
                      const SnackBar(
                        content: Text('Guest list saved successfully!'),
                      ),
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
                    const SnackBar(
                      content: Text('Guest list name cannot be empty.'),
                    ),
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
