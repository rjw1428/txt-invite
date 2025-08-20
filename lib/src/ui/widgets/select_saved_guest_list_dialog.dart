import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/services/api.dart';

class SelectSavedGuestListDialog extends StatefulWidget {
  const SelectSavedGuestListDialog({super.key});

  @override
  State<SelectSavedGuestListDialog> createState() => _SelectSavedGuestListDialogState();
}

class _SelectSavedGuestListDialogState extends State<SelectSavedGuestListDialog> {
  late Future<List<GuestList>> _guestListsFuture;

  @override
  void initState() {
    super.initState();
    final user = Api().auth.currentUser;
    _guestListsFuture = Api().guestLists.getGuestLists(user!.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a Saved Guest List'),
      content: FutureBuilder<List<GuestList>>(
        future: _guestListsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved guest lists found.'));
          } else {
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final guestList = snapshot.data![index];
                  return ListTile(
                    title: Text(guestList.name),
                    subtitle: Text('${guestList.guests.length} guests'),
                    onTap: () {
                      Navigator.of(context).pop(guestList);
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
