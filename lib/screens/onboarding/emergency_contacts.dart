import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hive/hive.dart';
import 'package:project_sih/models/emergency_contact.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyContacts extends StatefulWidget {
  final VoidCallback onFinish;
  final VoidCallback onPrevious;

  const EmergencyContacts({
    super.key,
    required this.onFinish,
    required this.onPrevious,
  });

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  final _formKey = GlobalKey<FormState>();
  final List<EmergencyContact> _emergencyContacts = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final box = Hive.box<EmergencyContact>('emergency_contacts');
    setState(() {
      _emergencyContacts.addAll(box.values);
    });
  }

  Future<void> _pickFromContacts() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final Contact? contact = await FlutterContacts.openExternalPick();
        if (contact != null && contact.phones.isNotEmpty) {
          setState(() {
            _emergencyContacts.add(
                EmergencyContact(contact.displayName, contact.phones.first.number));
          });
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error accessing contacts: $e")));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contacts permission denied")),
      );
    }
  }

  void _addManualContact() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _emergencyContacts.add(
            EmergencyContact(_nameController.text, _phoneController.text));
        _nameController.clear();
        _phoneController.clear();
      });
    }
  }

  void _removeContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }

  Future<void> _saveContacts() async {
    final box = Hive.box<EmergencyContact>('emergency_contacts');
    await box.clear();
    for (var contact in _emergencyContacts) {
      await box.add(contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _emergencyContacts.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Scaffold(
        appBar: AppBar(title: const Text("Add Emergency Contacts")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Please add at least one emergency contact. "
                "You can choose from your phone contacts or enter manually.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Manual Entry
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Enter name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Enter 10-digit phone number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (value.length != 10) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addManualContact,
                child: const Text("Add Manually"),
              ),
              const SizedBox(height: 20),

              // Pick from contacts
              ElevatedButton.icon(
                onPressed: _pickFromContacts,
                icon: const Icon(Icons.contacts),
                label: const Text("Pick from Contacts"),
              ),

              const SizedBox(height: 20),

              // Show added contacts
              Expanded(
                child: ListView.builder(
                  itemCount: _emergencyContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _emergencyContacts[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeContact(index),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onPrevious,
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    onPressed: canProceed
                        ? () {
                            _saveContacts();
                            widget.onFinish();
                          }
                        : null,
                    child: const Text("Finish"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
