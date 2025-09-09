import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PatientRegisterPage extends StatefulWidget {
  @override
  _PatientRegisterPageState createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final Dio _dio;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio();
    if (kIsWeb) _dio.options.extra['withCredentials'] = true;
  }

  Future<void> _register() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all required fields.";
        _successMessage = null;
      });
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _dio.post(
        "http://localhost:8084/api/patient/auth/register",
        data: {
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "age": int.parse(_ageController.text),
          "gender": _selectedGender,
          "phoneNumber": _phoneController.text,
          "email": _emailController.text,
          "address": _addressController.text,
          "medicalHistory": _medicalHistoryController.text.isEmpty
              ? "None"
              : _medicalHistoryController.text,
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _successMessage = "Registration successful! Please login with your credentials.";
        });
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = "Registration failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Patient Registration"),
        backgroundColor: const Color.fromARGB(255, 48, 105, 36),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person_add_outlined, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "Create Patient Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Name Fields
              TextField(controller: _firstNameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("First Name *", Icons.person_outline)),
              const SizedBox(height: 16),
              TextField(controller: _lastNameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Last Name *", Icons.person_outline)),
              const SizedBox(height: 16),

              // Age & Gender
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Age *", Icons.calendar_today_outlined),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      dropdownColor: const Color(0xFF1F1F1F),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Gender *", Icons.transgender_outlined),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender, style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedGender = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Other Fields
              TextField(controller: _phoneController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.phone, decoration: _inputDecoration("Phone Number *", Icons.phone_outlined)),
              const SizedBox(height: 16),
              TextField(controller: _emailController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.emailAddress, decoration: _inputDecoration("Email *", Icons.email_outlined)),
              const SizedBox(height: 16),
              TextField(controller: _addressController, style: const TextStyle(color: Colors.white), maxLines: 2, decoration: _inputDecoration("Address *", Icons.location_on_outlined)),
              const SizedBox(height: 16),
              TextField(controller: _medicalHistoryController, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: _inputDecoration("Medical History (Optional)", Icons.medical_services_outlined)),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, style: const TextStyle(color: Colors.white), obscureText: true, decoration: _inputDecoration("Password *", Icons.lock_outline)),
              const SizedBox(height: 16),
              TextField(controller: _confirmPasswordController, style: const TextStyle(color: Colors.white), obscureText: true, decoration: _inputDecoration("Confirm Password *", Icons.lock_outline)),
              const SizedBox(height: 24),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 16),

              // Already have account
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login", style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
              ),

              // Success Message
              if (_successMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[900]?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_successMessage!, style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[900]?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
