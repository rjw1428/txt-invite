import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';

class GuestListReviewScreen extends StatefulWidget {
  final List<Guest> initialGuests;

  const GuestListReviewScreen({super.key, required this.initialGuests});

  @override
  State<GuestListReviewScreen> createState() => _GuestListReviewScreenState();
}

class _GuestListReviewScreenState extends State<GuestListReviewScreen> {
  final TextEditingController _guestListNameController = TextEditingController();
  // final GuestListService _guestListService = GuestListService();
  late List<Guest> _guests;

  @override
  void initState() {
    super.initState();
    _guests = List.from(widget.initialGuests);
  }

  @override
  void dispose() {
    _guestListNameController.dispose();
    super.dispose();
  }

  void _removeGuest(int index) {
    setState(() {
      _guests.removeAt(index);
    });
  }

  void _saveGuestList() async {
    if (_guestListNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the guest list.')),
      );
      return;
    }

    if (_guests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest list cannot be empty.')),
      );
      return;
    }

    final newGuestList = GuestList(
      name: _guestListNameController.text.trim(),
      guests: _guests,
    );

    try {
      // await _guestListService.saveGuestList(newGuestList);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest list saved successfully!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Go back to the first screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save guest list: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Guest List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _guestListNameController,
              decoration: const InputDecoration(
                labelText: 'Guest List Name',
                hintText: 'e.g., Family & Friends, Work Colleagues',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _guests.isEmpty
                  ? const Center(child: Text('No guests added yet.'))
                  : ListView.builder(
                      itemCount: _guests.length,
                      itemBuilder: (context, index) {
                        final guest = _guests[index];
                        return ListTile(
                          title: Text('${guest.firstName ?? ''} ${guest.lastName ?? ''}'),
                          subtitle: Text(guest.phoneNumber),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => _removeGuest(index),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: _saveGuestList,
              child: const Text('Save Guest List'),
            ),
          ],
        ),
      ),
    );
  }
}