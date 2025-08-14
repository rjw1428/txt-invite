import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/ui/screens/manual_guest_entry_screen.dart';
import 'package:txt_invite/src/ui/screens/device_contact_selection_screen.dart';
import 'package:txt_invite/src/ui/screens/guest_list_review_screen.dart';

class GuestListSelectionScreen extends StatefulWidget {
  const GuestListSelectionScreen({super.key});

  @override
  State<GuestListSelectionScreen> createState() => GuestListSelectionScreenState();
}

class GuestListSelectionScreenState extends State<GuestListSelectionScreen> {
  List<Guest> _currentGuests = [];

  void _navigateAndAddGuestsManually() async {
    final newGuest = await showModalBottomSheet<Guest>(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to be full height if needed
      builder: (context) => const ManualGuestEntryScreen(),
    );
    if (newGuest != null) {
      setState(() {
        _currentGuests.add(newGuest);
      });
      _navigateToReviewScreen();
    }
  }

  void _navigateAndSelectContacts() async {
    final List<Guest>? selectedGuests = await Navigator.push<List<Guest>>(
      context,
      MaterialPageRoute(builder: (context) => const DeviceContactSelectionScreen()),
    );
    if (selectedGuests != null && selectedGuests.isNotEmpty) {
      setState(() {
        _currentGuests.addAll(selectedGuests);
      });
      _navigateToReviewScreen();
    }
  }

  void _navigateToReviewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestListReviewScreen(initialGuests: _currentGuests),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Guest List'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _navigateAndAddGuestsManually,
              child: const Text('Add Guests Manually'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateAndSelectContacts,
              child: const Text('Select from Device Contacts'),
            ),
            const SizedBox(height: 20),
            if (_currentGuests.isNotEmpty)
              ElevatedButton(
                onPressed: _navigateToReviewScreen,
                child: Text('Review Current Guests (${_currentGuests.length})'),
              ),
          ],
        ),
      ),
    );
  }
}