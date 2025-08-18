
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/ui/screens/add_edit_guest_screen.dart';

class GuestListCard extends StatefulWidget {
  final GuestList guestList;
  final VoidCallback onDelete;
  final Function(Guest) onDeleteGuest;
  final Function(Guest) onSaveGuest;

  const GuestListCard({
    super.key,
    required this.guestList,
    required this.onDelete,
    required this.onDeleteGuest,
    required this.onSaveGuest,
  });

  @override
  State<GuestListCard> createState() => _GuestListCardState();
}

class _GuestListCardState extends State<GuestListCard> {
  late GuestList? _guestList;

  void _addGuestToList(Guest guest, StateSetter setState) {
    if (_guestList != null) {

      if (guest.id != null) {
        final copy = List<Guest>.from(_guestList!.guests);
        final index = copy.indexWhere((g) => g.id == guest.id);
        if (index != -1) {
          copy[index] = guest;
          final updatedGuestList = _guestList!.copyWith(id: _guestList!.id!, guests: copy);
          setState(() {
            _guestList = updatedGuestList;
          });
          return;
        }
      }
      final updatedGuests = List<Guest>.from(_guestList!.guests)..add(guest);
      final updatedGuestList = _guestList!.copyWith(id: _guestList!.id!, guests: updatedGuests);
      setState(() {
        _guestList = updatedGuestList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _guestList = widget.guestList;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(widget.guestList.name),
        subtitle: Text('${widget.guestList.guests.length} guests'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: widget.onDelete,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(widget.guestList.name),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: _guestList!.guests.isEmpty
                          ? const Text('This guest list is empty.')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _guestList?.guests.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                final guest = _guestList!.guests[index];
                                return ListTile(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Edit Guest'),
                                          content: AddEditGuestScreen(
                                            guest: guest,
                                            onSave: (updatedGuest) async {
                                              await widget.onSaveGuest(updatedGuest);
                                              _addGuestToList(updatedGuest, setState);
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
                                      final updatedGuests = List<Guest>.from(_guestList!.guests)..remove(guest);
                                      final updatedGuestList = _guestList!.copyWith(id: _guestList!.id!, guests: updatedGuests);
                                      setState(() {
                                        _guestList = updatedGuestList;
                                      });
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
                                  onSave: (newGuest) async {
                                    await widget.onSaveGuest(newGuest);
                                    _addGuestToList(newGuest, setState);
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
                }
              );
            },
          );
        },
      ),
    );
  }
}
