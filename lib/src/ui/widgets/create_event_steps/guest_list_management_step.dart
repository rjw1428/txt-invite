import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/models/user.dart';
import 'package:txt_invite/src/services/api.dart';

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
    final Future<User?> currentUserFuture = Api().auth.currentUser;
    return FutureBuilder<User?>(
      future: currentUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No guest lists found.'));
        } else {
          final User currentUser = snapshot.data!;
          return FutureBuilder<List<GuestList>>(
            future: _fetchGuestLists(currentUser.id),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                                                  _selectedGuestListId ==
                                                  guestList.id;
                                              return Card(
                                                color:
                                                    isSelected
                                                        ? Colors.blue.shade100
                                                        : Colors.white,
                                                elevation: isSelected ? 4 : 1,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: ListTile(
                                                  title: Text(guestList.name),
                                                  subtitle: Text(
                                                    '${guestList.guests.length} guests',
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedGuestListId =
                                                          guestList.id;
                                                      state.didChange(
                                                        guestList.id,
                                                      );
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
                                        color:
                                            Theme.of(context).colorScheme.error,
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
                            // Navigate to screen to create new guest list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Create new guest list (not implemented)',
                                ),
                              ),
                            );
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
      },
    );
  }
}
