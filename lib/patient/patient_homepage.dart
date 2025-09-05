import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import './report_upload_page.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late final Dio _dio;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDio();
    });
  }

  void _initializeDio() {
    // Get the Dio instance passed from login page
    final Dio? passedDio = ModalRoute.of(context)?.settings.arguments as Dio?;

    if (passedDio != null) {
      _dio = passedDio;
    } else {
      // Create a new Dio instance with web configuration
      _dio = Dio();
      if (kIsWeb) {
        _dio.options.extra['withCredentials'] = true;
      }
    }

    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _dio.get(
        "http://localhost:8084/api/patient/auth/me",
      );

      if (response.statusCode == 200) {
        setState(() {
          _patientData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch patient data";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Dashboard"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
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
                    onPressed: _fetchPatientData,
                    child: Text("Retry"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchPatientData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Profile Card
                    _buildPatientProfileCard(),
                    SizedBox(height: 24),

                    // Services Section
                    Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Services Menu
                    Column(
                      children: [
                        _buildMenuCard(
                          icon: Icons.upload_file,
                          title: "Upload Report",
                          subtitle: "Upload your medical report",
                          color: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/uploadReport',
                              arguments: {
                                'dio': _dio,
                                'patientId': _patientData!['id'],
                              },
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        _buildMenuCard(
                          icon: Icons.book_online,
                          title: "Book Appointment",
                          subtitle: "Schedule your next visit",
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to booking
                          },
                        ),
                        SizedBox(height: 16),
                        _buildMenuCard(
                          icon: Icons.history,
                          title: "Medical History",
                          subtitle: "View your past records",
                          color: Colors.orange,
                          onTap: () {
                            // Navigate to history
                          },
                        ),
                        SizedBox(height: 16),
                        _buildMenuCard(
                          icon: Icons.receipt_long,
                          title: "Bills & Payments",
                          subtitle: "Manage your payments",
                          color: Colors.green,
                          onTap: () {
                            // Navigate to bills
                          },
                        ),
                        SizedBox(height: 16),
                        _buildMenuCard(
                          icon: Icons.medication,
                          title: "Prescriptions",
                          subtitle: "View your prescriptions",
                          color: Colors.purple,
                          onTap: () {
                            // Navigate to prescriptions
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

  Widget _buildPatientProfileCard() {
    if (_patientData == null) return SizedBox.shrink();

    String fullName =
        "${_patientData!['firstName']} ${_patientData!['lastName']}";

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[700]!, Colors.green[500]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      "${_patientData!['firstName'][0]}${_patientData!['lastName'][0]}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _patientData!['email'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "ID: ${_patientData!['id']}",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.3)),
              SizedBox(height: 20),

              // Patient Details Grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.cake,
                      label: "Age",
                      value: "${_patientData!['age']} years",
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.person,
                      label: "Gender",
                      value: _patientData!['gender'],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.phone,
                      label: "Phone",
                      value: _patientData!['phoneNumber'],
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.medical_services,
                      label: "Medical History",
                      value: _patientData!['medicalHistory'] ?? 'None',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailItem(
                icon: Icons.location_on,
                label: "Address",
                value: _patientData!['address'],
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment: fullWidth
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: fullWidth ? TextAlign.left : TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: fullWidth ? 2 : 1,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
