
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:txt_invite/src/models/guest.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;
  final Function(Guest) onSave;

  const AddEditGuestScreen({super.key, this.guest, required this.onSave});

  @override
  AddEditGuestScreenState createState() => AddEditGuestScreenState();
}

class AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  late final List<Contact> contacts;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.guest?.firstName ?? '';
    _lastNameController.text = widget.guest?.lastName ?? '';
    _phoneNumberController.text = widget.guest?.phoneNumber ?? '';
    _getContacts();
  }

  Future<void> _getContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      final importedContacts = await FlutterContacts.getContacts();
      setState(() => contacts = importedContacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guest == null ? 'Add Guest' : 'Edit Guest'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Autocomplete<Contact>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Contact>.empty();
                  }
                  print('CONTACTS: ${contacts.length}');
                  for (var i = 0; i < contacts.length && i < 10; i++) {
                    print('Contact ${i + 1}: ${contacts[i].name.toString()}');
                  }
                  return contacts.where((contact) {
                    final fullName = "${contact.name.first} ${contact.name.last}".toLowerCase();
                    return fullName.contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (Contact contact) => "${contact.name.first} ${contact.name.last}",
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Search Contacts'),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final contact = options.elementAt(index);
                            return ListTile(
                              title: Text('${contact.name.first} ${contact.name.last}'),
                              onTap: () {
                                onSelected(contact);
                                _firstNameController.text = contact.name.first;
                                _lastNameController.text = contact.name.last;
                                if (contact.phones.isNotEmpty) {
                                  _phoneNumberController.text = contact.phones.first.number;
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newGuest = Guest(
                      id: widget.guest?.id, // Use existing ID if editing
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      phoneNumber: _phoneNumberController.text,
                    );
                    widget.onSave(newGuest);
                    Navigator.of(context).pop(); // Go back to previous screen
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
