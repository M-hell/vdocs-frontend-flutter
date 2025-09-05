import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ClinicAppointmentDetailPage extends StatefulWidget {
  final Dio dio;
  final int appointmentId;

  const ClinicAppointmentDetailPage({
    super.key,
    required this.dio,
    required this.appointmentId,
  });

  @override
  State<ClinicAppointmentDetailPage> createState() =>
      _ClinicAppointmentDetailPageState();
}

class _ClinicAppointmentDetailPageState
    extends State<ClinicAppointmentDetailPage> {
  Map<String, dynamic>? appointment;
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _clinicReportController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchAppointmentDetail();
  }

  Future<void> fetchAppointmentDetail() async {
    try {
      final response = await widget.dio.get(
        "http://localhost:8084/api/clinic/appointments/${widget.appointmentId}",
      );

      setState(() {
        appointment = response.data;
        _remarksController.text = appointment?['remarks'] ?? '';
        _clinicReportController.text = appointment?['clinicReportUrl'] ?? '';
        _selectedStatus = appointment?['status'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load appointment details: $e";
        isLoading = false;
      });
    }
  }

  Future<void> updateAppointment() async {
    if (_selectedStatus == null) return;

    final body = {
      "status": _selectedStatus,
      "remarks": _remarksController.text,
      "appointmentDate": appointment?['appointmentDate'],
      "medicalRequirement": appointment?['medicalRequirement'],
      "clinicReportUrl": _clinicReportController.text,
    };

    try {
      await widget.dio.post(
        "http://localhost:8084/api/clinic/appointments/update/${widget.appointmentId}",
        data: body,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment updated successfully')),
      );

      fetchAppointmentDetail(); // Refresh details
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointment Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${appointment!['patientName']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Contact: ${appointment!['patientContactNo']}'),
                  const SizedBox(height: 8),
                  Text('Clinic: ${appointment!['clinic']['name']}'),
                  const SizedBox(height: 8),
                  Text(
                    'Appointment Date: ${DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.parse(appointment!['appointmentDate']))}',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['PENDING', 'COMPLETED', 'CANCELLED']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    value: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Remarks',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clinicReportController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Report URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: updateAppointment,
                    child: const Text('Update Appointment'),
                  ),
                ],
              ),
            ),
    );
  }
}
