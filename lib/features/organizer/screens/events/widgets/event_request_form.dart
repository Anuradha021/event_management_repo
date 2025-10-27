import 'package:event_management_app1/core/services/organizer_dashboard_service.dart';
import 'package:flutter/material.dart';

class ContactForm extends StatefulWidget {
  final bool skipOrganizerCheck;
  final bool isFromDashboard;
  const ContactForm({
    super.key,
    this.skipOrganizerCheck = false,
    required this.isFromDashboard,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();
  final TextEditingController _organizerNameController =
      TextEditingController();
  final TextEditingController _organizerEmailController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final result = await OrganizerDashboardService.submitEventRequest(
          eventTitle: _eventTitleController.text,
          eventDescription: _eventDescController.text,
          organizerName: _organizerNameController.text,
          organizerEmail: _organizerEmailController.text,
          location: _locationController.text,
          eventDate: _selectedDate!,
        );

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event request submitted successfully'),
            ),
          );

          _formKey.currentState!.reset();
          _eventTitleController.clear();
          _eventDescController.clear();
          _organizerNameController.clear();
          _organizerEmailController.clear();
          _locationController.clear();
          setState(() => _selectedDate = null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit request: ${result['message']}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request to Organize Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _eventTitleController,
                  decoration: const InputDecoration(
                    labelText: "Event Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _eventDescController,
                  decoration: const InputDecoration(
                    labelText: "Event Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _organizerNameController,
                  decoration: const InputDecoration(
                    labelText: "Organizer Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _organizerEmailController,
                  decoration: const InputDecoration(
                    labelText: "Organizer Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Event Location",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                // Date Picker with similar UI to other fields
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Event Date",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Select date'
                              : "${_selectedDate!.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Submit Request"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}