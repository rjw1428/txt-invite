import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';

class DeviceContactSelectionScreen extends StatefulWidget {
  const DeviceContactSelectionScreen({super.key});

  @override
  State<DeviceContactSelectionScreen> createState() => _DeviceContactSelectionScreenState();
}

class _DeviceContactSelectionScreenState extends State<DeviceContactSelectionScreen> {
  // final ContactService _contactService = ContactService();
  late Future<List<Guest>> _contactsFuture;
  final List<Guest> _selectedGuests = [];

  @override
  void initState() {
    super.initState();
    // _contactsFuture = _contactService.getDeviceContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedGuests);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Guest>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final guest = snapshot.data![index];
                final isSelected = _selectedGuests.contains(guest);
                return CheckboxListTile(
                  title: Text('${guest.firstName ?? ''} ${guest.lastName ?? ''}'),
                  subtitle: Text(guest.phoneNumber),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedGuests.add(guest);
                      } else {
                        _selectedGuests.remove(guest);
                      }
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}