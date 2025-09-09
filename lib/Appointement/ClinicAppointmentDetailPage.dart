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

      if (!mounted) return;
      setState(() {
        appointment = response.data;
        _remarksController.text = appointment?['remarks'] ?? '';
        _clinicReportController.text = appointment?['clinicReportUrl'] ?? '';
        _selectedStatus = appointment?['status'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment updated successfully')),
      );

      fetchAppointmentDetail();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'PENDING':
        return Colors.orangeAccent;
      case 'CANCELLED':
        return Colors.redAccent;
      case 'CONFIRMED':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 141, 130, 130),
        title: const Text("Appointment Details"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Info Card
                      Card(
                        color: const Color(0xFF1E1E1E),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 32, color: Colors.blueAccent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      appointment!['patientName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Contact: ${appointment!['patientContactNo'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Clinic: ${appointment!['clinic']['name'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Appointment Date: ${DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.parse(appointment!['appointmentDate']))}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    "Status: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                          appointment!['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      appointment!['status'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Medical Requirement Card
                      Card(
                        color: const Color(0xFF1E1E1E),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Medical Requirement",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appointment!['medicalRequirement'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Remarks
                      TextField(
                        controller: _remarksController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Clinic Report
                      TextField(
                        controller: _clinicReportController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Clinic Report URL',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF1E1E1E),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED']
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

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: updateAppointment,
                          icon: const Icon(Icons.save),
                          label: const Text("Update Appointment"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
