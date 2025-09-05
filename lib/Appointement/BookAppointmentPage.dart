import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  final Dio dio;
  final int patientId;
  final String patientName;
  final String patientContactNo;

  const BookAppointmentPage({
    super.key,
    required this.dio,
    required this.patientId,
    required this.patientName,
    required this.patientContactNo,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<dynamic> clinics = [];
  bool isLoading = true;
  dynamic selectedClinic;
  DateTime? selectedDate;
  final TextEditingController _medicalRequirementController =
      TextEditingController();
  final TextEditingController _reportUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    try {
      final response = await widget.dio.get(
        'http://localhost:8084/api/clinic/auth/all',
      );
      setState(() {
        clinics = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load clinics')));
    }
  }

  Future<void> submitAppointment() async {
    if (selectedClinic == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select clinic and date')),
      );
      return;
    }

    final body = {
      "patientId": widget.patientId,
      "patientName": widget.patientName,
      "patientContactNo": widget.patientContactNo,
      "clinicId": selectedClinic['id'],
      "appointmentDate": selectedDate!.toIso8601String(),
      "medicalRequirement": _medicalRequirementController.text,
      "patientReportUrl": _reportUrlController.text,
    };

    try {
      final response = await widget.dio.post(
        'http://localhost:8084/api/clinic/appointments/create',
        data: body,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );
      Navigator.pop(context, response.data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to book appointment')),
      );
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<dynamic>(
                    decoration: const InputDecoration(
                      labelText: 'Select Clinic',
                      border: OutlineInputBorder(),
                    ),
                    items: clinics
                        .map(
                          (clinic) => DropdownMenuItem(
                            value: clinic,
                            child: Text(clinic['name']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClinic = value;
                      });
                    },
                    value: selectedClinic,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: selectedDate == null
                          ? 'Pick Appointment Date & Time'
                          : 'Appointment: ${DateFormat('yyyy-MM-dd – HH:mm').format(selectedDate!)}',
                      border: const OutlineInputBorder(),
                    ),
                    onTap: pickDate,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _medicalRequirementController,
                    decoration: const InputDecoration(
                      labelText: 'Medical Requirement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reportUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Report URL (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submitAppointment,
                    child: const Text('Book Appointment'),
                  ),
                ],
              ),
            ),
    );
  }
}
