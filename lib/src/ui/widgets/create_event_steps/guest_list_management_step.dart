import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/ui/screens/add_edit_guest_screen.dart';
import 'package:txt_invite/src/ui/widgets/select_saved_guest_list_dialog.dart';

class GuestListManagementStep extends StatefulWidget {
  final Function(List<Guest>) onGuestListChanged;
  final List<Guest> guestList;
  final GlobalKey<FormState> formKey;

  const GuestListManagementStep({
    super.key,

    required this.onGuestListChanged,
    required this.guestList,
    required this.formKey,
  });

  @override
  State<GuestListManagementStep> createState() =>
      _GuestListManagementStepState();
}

class _GuestListManagementStepState extends State<GuestListManagementStep> {
  List<Guest> currentSelectedGuestList = [];

  @override
  void initState() {
    super.initState();
    currentSelectedGuestList = widget.guestList;
  }


  void addGuest() async {
    final newGuest = await showDialog<Guest>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: AddEditGuestScreen(
            onSave: (guest) async {
              // This onSave is for the single guest, not the list
            },
          ),
        );
      },
    );
    if (newGuest != null) {
      setState(() {
        currentSelectedGuestList.add(newGuest);
      });
      widget.onGuestListChanged(currentSelectedGuestList);
    }
  }

  void editGuest(Guest guest) async {
    final updatedGuest = await showDialog<Guest>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: AddEditGuestScreen(
            guest: guest,
            onSave: (guest) async {
              // This onSave is for the single guest, not the list
            },
          ),
        );
      },
    );
    if (updatedGuest != null) {
      setState(() {
        final index = currentSelectedGuestList.indexWhere((g) => g.id == updatedGuest.id);
        if (index != -1) {
          currentSelectedGuestList[index] = updatedGuest;
        }
      });
      widget.onGuestListChanged(currentSelectedGuestList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child:
                  currentSelectedGuestList.isEmpty
                      ? const Center(child: Text('No guests added yet.'))
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: currentSelectedGuestList.length,
                        itemBuilder: (context, index) {
                          final guest = currentSelectedGuestList[index];
                          return ListTile(
                            onTap: () => editGuest(guest),
                            title: Text('${guest.firstName} ${guest.lastName}'),
                            subtitle: Text(guest.phoneNumber),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  currentSelectedGuestList.removeAt(index);
                                });
                                widget.onGuestListChanged(currentSelectedGuestList);
                              },
                            ),
                          );
                        },
                      ),
            ),
            TextFormField(
              validator: (value) {
                if (currentSelectedGuestList.isEmpty) {
                  return 'Please add at least one guest.';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(height: 0, fontSize: 0),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addGuest,
              child: const Text('Add Guest'),
            ),
            const SizedBox(height: 8), // Add some spacing
            ElevatedButton(
              onPressed: () async {
                final selectedGuestList = await showDialog<GuestList>(
                  context: context,
                  builder: (context) => const SelectSavedGuestListDialog(),
                );
                if (selectedGuestList != null) {
                  setState(() {
                    currentSelectedGuestList = selectedGuestList.guests;
                  });
                  widget.onGuestListChanged(currentSelectedGuestList);
                }
              },
              child: const Text('Select from Saved Guest List'),
            ),
            const SizedBox(height: 8), // Add some spacing
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentSelectedGuestList.clear();
                });
                widget.onGuestListChanged(currentSelectedGuestList);
              },
              child: const Text('Clear Guest List'),
            ),
          ],
        ),
      ),
    );
  }
}
