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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load clinics')),
      );
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
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[700],
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDropdownField(),
                  const SizedBox(height: 16),
                  _buildDatePickerField(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _medicalRequirementController,
                    label: 'Medical Requirement',
                    icon: Icons.medical_services,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _reportUrlController,
                    label: 'Report URL (optional)',
                    icon: Icons.upload_file,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: submitAppointment,
                      icon: const Icon(Icons.book_online),
                      label: const Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<dynamic>(
      decoration: InputDecoration(
        labelText: 'Select Clinic',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.local_hospital),
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
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: selectedDate == null
            ? 'Pick Appointment Date & Time'
            : 'Appointment: ${DateFormat('yyyy-MM-dd – HH:mm').format(selectedDate!)}',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: pickDate,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
