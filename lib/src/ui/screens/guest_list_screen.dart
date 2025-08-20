
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/guest_list.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/widgets/guest_list_card.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  late Future<List<GuestList>> _guestListsFuture;

  @override
  void initState() {
    super.initState();
    _fetchGuestLists();
  }

  void _fetchGuestLists() {
    final currentUser = Api().auth.currentUser;
    if (currentUser != null) {
      _guestListsFuture = Api().guestLists.getGuestLists(currentUser.id);
    } else {
      _guestListsFuture = Future.value([]);     }
  }

  Future<void> _createNewGuestList() async {
    String? guestListName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? newName;
        return AlertDialog(
          title: const Text('Create New Guest List'),
          content: TextField(
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              newName = value;
            },
            decoration: const InputDecoration(hintText: 'Guest List Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () {
                Navigator.pop(context, newName);
              },
            ),
          ],
        );
      },
    );

    if (guestListName != null && guestListName.isNotEmpty) {
      final currentUser = Api().auth.currentUser;
      if (currentUser != null) {
        try {
          final newGuestList = GuestList(
            name: guestListName,
            createdBy: currentUser.id,
            guests: [],
            createdAt: DateTime.now()
          );
          await Api().guestLists.createGuestList(newGuestList);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guest list created successfully!')),
          );
          setState(() {
            _fetchGuestLists(); // Refresh the list
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create guest list: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteGuestList(String guestListId) async {
    try {
      await Api().guestLists.deleteGuestList(guestListId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest list deleted successfully!')),
      );
      setState(() {
        _fetchGuestLists(); // Refresh the list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete guest list: $e')),
      );
    }
  }

  Future<void> _deleteGuest(String guestListId, Guest guest) async {
    try {
      await Api().guestLists.deleteGuest(guestListId, guest);
      setState(() {
        _fetchGuestLists(); // Refresh the list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete guest: $e')),
      );
    }
  }

  Future<void> _saveGuest(String guestListId, Guest guest) async {
    try {
      if (guest.id == null) {
        await Api().guestLists.addGuest(guestListId, guest);
      } else {
        await Api().guestLists.updateGuest(guestListId, guest);
      }
      setState(() {
        _fetchGuestLists(); // Refresh the list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save guest: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/');
          },
        ),
        title: const Text('Manage Guest Lists'),
      ),
      body: FutureBuilder<List<GuestList>>(
        future: _guestListsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No guest lists found. Create one!'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final guestList = snapshot.data![index];
              return GuestListCard(
                guestList: guestList,
                onDelete: () => _deleteGuestList(guestList.id!),
                onDeleteGuest: (guest) => _deleteGuest(guestList.id!, guest),
                onSaveGuest: (guest) => _saveGuest(guestList.id!, guest),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewGuestList,
        child: const Icon(Icons.add),
      ),
    );
  }
}
