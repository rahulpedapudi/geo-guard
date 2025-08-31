import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
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
  final List<String> _emergencyContacts = [];
  final TextEditingController _manualController = TextEditingController();

  Future<void> _pickFromContacts() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final Contact? contact =
            await ContactsService.openDeviceContactPicker();
        if (contact != null && contact.phones!.isNotEmpty) {
          setState(() {
            _emergencyContacts.add(contact.phones!.first.value ?? '');
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
    if (_manualController.text.isNotEmpty) {
      setState(() {
        _emergencyContacts.add(_manualController.text);
        _manualController.clear();
      });
    }
  }

  void _removeContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualController,
                      decoration: const InputDecoration(
                        labelText: "Enter phone number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addManualContact,
                    child: const Text("Add"),
                  ),
                ],
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
                    return ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(_emergencyContacts[index]),
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
                    onPressed: canProceed ? widget.onFinish : null,
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
