import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/models/user.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/screens/add_edit_guest_screen.dart';

class GuestListManagementStep extends StatefulWidget {
  final Function(String) onGuestListSelected;
  final GlobalKey<FormState> formKey;

  const GuestListManagementStep({
    super.key,
    required this.onGuestListSelected,
    required this.formKey,
  });

  @override
  State<GuestListManagementStep> createState() =>
      _GuestListManagementStepState();
}

class _GuestListManagementStepState extends State<GuestListManagementStep> {
  String? _selectedGuestListId;

  @override
  void initState() {
    super.initState();
  }

  Future<List<GuestList>> _fetchGuestLists(String userId) async {
    return await Api().guestLists.getGuestLists(userId);
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = Api().auth.currentUser;
    return FutureBuilder<List<GuestList>>(
      future: _fetchGuestLists(currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No guest lists found.'));
        } else {
          final guestLists = snapshot.data!;
          return Form(
            key: widget.formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Guest Lists',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FormField<String>(
                      validator: (value) {
                        if (_selectedGuestListId == null) {
                          return 'Please select a guest list';
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: guestLists.length,
                                itemBuilder: (context, index) {
                                  final guestList = guestLists[index];
                                  final isSelected =
                                      _selectedGuestListId == guestList.id;
                                  return Card(
                                    color:
                                        isSelected
                                            ? Colors.blue.shade100
                                            : Colors.white,
                                    elevation: isSelected ? 4 : 1,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: ListTile(
                                      title: Text(guestList.name),
                                      subtitle: Text(
                                        '${guestList.guests.length} guests',
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedGuestListId = guestList.id;
                                          state.didChange(guestList.id);
                                        });
                                        widget.onGuestListSelected(
                                          guestList.id!,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (state.hasError)
                              Text(
                                state.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showCreateGuestListDialog(context);
                    },
                    child: const Text('Create New Guest List'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _showCreateGuestListDialog(BuildContext context) {
    final nameController = TextEditingController();
    final List<Guest> guests = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Guest List'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Guest List Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: guests.length,
                        itemBuilder: (context, index) {
                          final guest = guests[index];
                          return ListTile(
                            title: Text('${guest.firstName} ${guest.lastName}'),
                            subtitle: Text(guest.phoneNumber),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: AddEditGuestScreen(
                                onSave: (guest) async {
                                  setState(() {
                                    guests.add(guest);
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Add Guest'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      final newGuestList = GuestList(
                        name: nameController.text,
                        guests: guests,
                        id: '', // Firestore will generate the ID
                        createdBy: Api().auth.currentUser!.id,
                      );
                      final createdGuestList = await Api().guestLists
                          .createGuestList(newGuestList);
                      setState(() {
                        _selectedGuestListId = createdGuestList.id;
                      });
                      widget.onGuestListSelected(createdGuestList.id!);
                      Navigator.of(context).pop();
                      // Refresh the list of guest lists
                      setState(() {});
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
