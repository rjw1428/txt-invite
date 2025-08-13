
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/services/api.dart';

class GuestListManagementStep extends StatefulWidget {
  final Function(String) onGuestListSelected;

  const GuestListManagementStep({super.key, required this.onGuestListSelected});

  @override
  State<GuestListManagementStep> createState() => _GuestListManagementStepState();
}

class _GuestListManagementStepState extends State<GuestListManagementStep> {
  late Future<List<GuestList>> _guestListsFuture;
  String? _selectedGuestListId;

  @override
  void initState() {
    super.initState();
    _guestListsFuture = _fetchGuestLists();
  }

  Future<List<GuestList>> _fetchGuestLists() async {
    return await Api().guestLists.getGuestLists();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: FutureBuilder<List<GuestList>>(
              future: _guestListsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No guest lists found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final guestList = snapshot.data![index];
                      final isSelected = _selectedGuestListId == guestList.id;
                      return Card(
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        elevation: isSelected ? 4 : 1,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(guestList.name),
                          subtitle: Text('${guestList.guests.length} guests'),
                          onTap: () {
                            setState(() {
                              _selectedGuestListId = guestList.id;
                            });
                            widget.onGuestListSelected(guestList.id!);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to screen to create new guest list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create new guest list (not implemented)')),
              );
            },
            child: const Text('Create New Guest List'),
          ),
        ],
      ),
    );
  }
}
