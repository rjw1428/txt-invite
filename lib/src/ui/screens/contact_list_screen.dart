
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact>? _contacts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }


  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final hasPermission = await FlutterContacts.requestPermission(readonly: true);
      if (hasPermission) {
        final contacts = await FlutterContacts.getContacts(withPhoto: true, withProperties: true);
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Permission denied';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading contacts: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Contact'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      if (_error == 'Permission denied') {
        return Center(
          child: const Text('Permission to access contacts was denied.'),
        );
      }
      return Center(child: Text(_error!));
    }
    if (_contacts == null || _contacts!.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, index) {
        final contact = _contacts![index];
        return ListTile(
          title: Text(contact.displayName),
          onTap: () {
            Navigator.of(context).pop(contact);
          },
        );
      },
    );
  }
}
