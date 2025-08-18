
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/ui/screens/add_edit_guest_screen.dart';

class GuestListDetailDialog extends StatefulWidget {
  final GuestList guestList;
  final Function(Guest) onDeleteGuest;
  final Function(Guest) onSaveGuest;

  const GuestListDetailDialog({
    super.key,
    required this.guestList,
    required this.onDeleteGuest,
    required this.onSaveGuest,
  });

  @override
  State<GuestListDetailDialog> createState() => _GuestListDetailDialogState();
}

class _GuestListDetailDialogState extends State<GuestListDetailDialog> {
  late GuestList _currentGuestList;

  @override
  void initState() {
    super.initState();
    _currentGuestList = widget.guestList;
  }

  void _refreshGuestList() {
    // This is a placeholder. In a real app, you'd re-fetch the guest list
    // from your API or update it from a state management solution.
    // For now, we'll just simulate an update.
    setState(() {
      // This will trigger a rebuild of the dialog content
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_currentGuestList.name),
      content: SizedBox(
        width: double.maxFinite,
        child: _currentGuestList.guests.isEmpty
            ? const Text('This guest list is empty.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _currentGuestList.guests.length,
                itemBuilder: (BuildContext context, int index) {
                  final guest = _currentGuestList.guests[index];
                  return ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Edit Guest'),
                            content: AddEditGuestScreen(
                              guest: guest,
                              onSave: (updatedGuest) {
                                widget.onSaveGuest(updatedGuest);
                                _refreshGuestList(); // Refresh the dialog
                                Navigator.of(context).pop(); // Close the AddEditGuestScreen dialog
                              },
                            ),
                          );
                        },
                      );
                    },
                    title: Text('${guest.firstName} ${guest.lastName}'),
                    subtitle: Text(guest.phoneNumber),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        widget.onDeleteGuest(guest);
                        _refreshGuestList(); // Refresh the dialog
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Add Guest'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddEditGuestScreen(
                  onSave: (newGuest) {
                    widget.onSaveGuest(newGuest);
                    _refreshGuestList(); // Refresh the dialog
                    Navigator.of(context).pop(); // Close the AddEditGuestScreen dialog
                  },
                );
              },
            );
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
