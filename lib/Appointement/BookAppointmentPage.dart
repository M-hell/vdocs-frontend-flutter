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
  List<dynamic> patientReports = [];
  bool isLoading = true;
  bool isLoadingReports = false;
  dynamic selectedClinic;
  dynamic selectedReport;
  DateTime? selectedDate;
  final TextEditingController _medicalRequirementController =
      TextEditingController();
  final TextEditingController _reportUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchClinics();
    await fetchPatientReports();
  }

  Future<void> fetchClinics() async {
    try {
      final response = await widget.dio.get(
        'http://localhost:8080/api/clinic/auth/all',
      );
      if (mounted) {
        setState(() {
          clinics = response.data ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          clinics = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load clinics: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> fetchPatientReports() async {
    if (mounted) {
      setState(() {
        isLoadingReports = true;
      });
    }

    try {
      final response = await widget.dio.get(
        'http://localhost:8080/api/patient/reports/patient/${widget.patientId}',
      );
      
      if (mounted) {
        setState(() {
          patientReports = response.data ?? [];
          isLoadingReports = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          patientReports = [];
          isLoadingReports = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: ${e.toString()}')),
        );
      }
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
        'http://localhost:8080/api/clinic/appointments/create',
        data: body,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully')),
        );
        Navigator.pop(context, response.data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book appointment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
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
                  _buildReportDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _reportUrlController,
                    label: 'Report URL (Auto-filled or manual)',
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

  Widget _buildReportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.folder, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Select Patient Report (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isLoadingReports)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (patientReports.isEmpty && !isLoadingReports)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text(
              'No reports found for this patient',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        else if (!isLoadingReports && patientReports.isNotEmpty)
          DropdownButtonFormField<dynamic>(
            decoration: const InputDecoration(
              labelText: 'Choose Report',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            value: selectedReport,
            isExpanded: true,
            items: [
              const DropdownMenuItem<dynamic>(
                value: null,
                child: Text('Select a report...'),
              ),
              ...patientReports.map<DropdownMenuItem<dynamic>>((report) {
                final fileName = report['originalName'] ?? 'Unknown File';
                final category = report['category'] ?? 'No Category';
                final uploadDate = report['uploadedAt'] != null 
                    ? DateFormat('MMM dd, yyyy').format(DateTime.parse(report['uploadedAt']))
                    : 'Unknown Date';
                final hasUrl = report['fileUrl'] != null && report['fileUrl'].toString().isNotEmpty;
                
                return DropdownMenuItem<dynamic>(
                  value: report,
                  enabled: hasUrl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: hasUrl ? Colors.black : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUrl ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                      Text(
                        uploadDate + (hasUrl ? '' : ' (No URL)'),
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUrl ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                selectedReport = value;
                if (value != null && value['fileUrl'] != null) {
                  _reportUrlController.text = value['fileUrl'].toString();
                } else if (value == null) {
                  _reportUrlController.clear();
                }
              });
            },
          ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<dynamic>(
      decoration: const InputDecoration(
        labelText: 'Select Clinic',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_hospital),
      ),
      value: selectedClinic,
      items: clinics.map<DropdownMenuItem<dynamic>>((clinic) {
        return DropdownMenuItem<dynamic>(
          value: clinic,
          child: Text(clinic['name']?.toString() ?? 'Unknown Clinic'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedClinic = value;
        });
      },
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
