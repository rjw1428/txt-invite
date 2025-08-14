
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/ui/screens/add_edit_guest_screen.dart';

class GuestListCard extends StatelessWidget {
  final GuestList guestList;
  final VoidCallback onDelete;
  final Function(Guest) onDeleteGuest;
  final Function(Guest) onSaveGuest;
  final VoidCallback onGuestListChanged;

  const GuestListCard({
    super.key,
    required this.guestList,
    required this.onDelete,
    required this.onDeleteGuest,
    required this.onSaveGuest,
    required this.onGuestListChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(guestList.name),
        subtitle: Text('${guestList.guests.length} guests'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(guestList.name),
                content: SizedBox(
                  width: double.maxFinite,
                  child: guestList.guests.isEmpty
                      ? const Text('This guest list is empty.')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: guestList.guests.length,
                          itemBuilder: (BuildContext context, int index) {
                            final guest = guestList.guests[index];
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
                                          onSaveGuest(updatedGuest);
                                          onGuestListChanged(); // Call to refresh the dialog
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
                                  onDeleteGuest(guest);
                                  onGuestListChanged(); // Call to refresh the dialog
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
                          return AlertDialog(
                            title: const Text('Add Guest'),
                            content: AddEditGuestScreen(
                              onSave: (newGuest) {
                                onSaveGuest(newGuest);
                                onGuestListChanged(); // Call to refresh the dialog
                              },
                            ),
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
            },
          );
        },
      ),
    );
  }
}
