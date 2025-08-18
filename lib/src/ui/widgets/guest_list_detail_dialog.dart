
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/services/api.dart';
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

  void _refreshGuestList() async {
    final updatedGuestList = await Api().guestLists.getGuestList(_currentGuestList.id!);
    if (updatedGuestList != null) {
      setState(() {
        _currentGuestList = updatedGuestList;
      });
    }
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditGuestScreen(
                            guest: guest,
                            onSave: (updatedGuest) async {
                              await widget.onSaveGuest(updatedGuest);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ).then((_) => _refreshGuestList());
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditGuestScreen(
                  onSave: (newGuest) async {
                    await widget.onSaveGuest(newGuest);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ).then((_) => _refreshGuestList());
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
