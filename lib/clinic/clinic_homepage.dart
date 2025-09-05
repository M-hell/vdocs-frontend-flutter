import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../Appointement/ClinicAppointmentsPage.dart'; // Your existing page

class ClinicHomePage extends StatefulWidget {
  @override
  _ClinicHomePageState createState() => _ClinicHomePageState();
}

class _ClinicHomePageState extends State<ClinicHomePage> {
  late final Dio _dio;
  Map<String, dynamic>? _clinicData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDio();
    });
  }

  void _initializeDio() {
    final Dio? passedDio = ModalRoute.of(context)?.settings.arguments as Dio?;

    if (passedDio != null) {
      _dio = passedDio;
    } else {
      _dio = Dio();
      if (kIsWeb) {
        _dio.options.extra['withCredentials'] = true;
      }
    }

    _fetchClinicData();
  }

  Future<void> _fetchClinicData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _dio.get(
        "http://localhost:8084/api/clinic/auth/me",
      );

      if (response.statusCode == 200) {
        setState(() {
          _clinicData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch clinic data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCompletedAppointments() async {
    try {
      final response = await _dio.get(
        "http://localhost:8084/api/clinic/appointments/completed",
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointments = response.data;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompletedAppointmentsPage(
              dio: _dio,
              appointments: appointments,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch appointments: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clinic Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchClinicData,
                    child: Text("Retry"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchClinicData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClinicInfoCard(),
                    SizedBox(height: 24),
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildDashboardCard(
                          icon: Icons.people,
                          title: "Patients",
                          onTap: _fetchCompletedAppointments,
                        ),
                        _buildDashboardCard(
                          icon: Icons.calendar_today,
                          title: "Appointments",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClinicAppointmentsPage(dio: _dio),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildClinicInfoCard() {
    if (_clinicData == null) return SizedBox.shrink();

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, size: 32, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _clinicData!['name'] ?? 'Unknown Clinic',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.email,
              label: "Email",
              value: _clinicData!['email'] ?? 'N/A',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone,
              label: "Contact",
              value: _clinicData!['contactNo'] ?? 'N/A',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_on,
              label: "Address",
              value: _clinicData!['address'] ?? 'N/A',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Created",
              value: _formatDate(_clinicData!['createdAt']),
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.update,
              label: "Last Updated",
              value: _formatDate(_clinicData!['updatedAt']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- CompletedAppointmentsPage ----------------

class CompletedAppointmentsPage extends StatelessWidget {
  final Dio dio;
  final List<dynamic> appointments;

  const CompletedAppointmentsPage({
    super.key,
    required this.dio,
    required this.appointments,
  });

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
      appBar: AppBar(title: Text("Completed Appointments")),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final clinic = appointment['clinic'] ?? {};
          final status = appointment['status'] ?? 'Unknown';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(appointment['patientName'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clinic: ${clinic['name'] ?? 'N/A'}"),
                  Text("Date: ${appointment['appointmentDate'] ?? 'N/A'}"),
                  Text(
                    "Medical Requirement: ${appointment['medicalRequirement'] ?? 'N/A'}",
                  ),
                  Text("Remarks: ${appointment['remarks'] ?? ''}"),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ),
          );
        },
      ),
    );
  }
}
