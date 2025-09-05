import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Appointement/ClinicAppointmentDetailPage.dart';

class ClinicAppointmentsPage extends StatefulWidget {
  final Dio dio;

  const ClinicAppointmentsPage({super.key, required this.dio});

  @override
  _ClinicAppointmentsPageState createState() => _ClinicAppointmentsPageState();
}

class _ClinicAppointmentsPageState extends State<ClinicAppointmentsPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await widget.dio.get(
        "http://localhost:8084/api/clinic/appointments/all",
      );

      setState(() {
        _appointments = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  // Function to get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointments")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                final clinicName =
                    appointment['clinic']?['name'] ?? 'Unknown Clinic';
                final status = appointment['status'] ?? 'Unknown';
                final medicalRequirement =
                    appointment['medicalRequirement'] ?? '';
                final date = appointment['appointmentDate'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text("${appointment['patientName']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Clinic: $clinicName"),
                        Text("Date: $date"),
                        Text("Medical Requirement: $medicalRequirement"),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClinicAppointmentDetailPage(
                            dio: widget.dio,
                            appointmentId: appointment['id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
