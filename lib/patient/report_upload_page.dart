import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportUploadPage extends StatefulWidget {
  @override
  _ReportUploadPageState createState() => _ReportUploadPageState();
}

class _ReportUploadPageState extends State<ReportUploadPage> {
  late Dio _dio;
  late int _patientId;
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _message;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments passed from the previous page
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _dio = args['dio'] as Dio;
    _patientId = args['patientId'] as int;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _message = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _message = "Please select a file first.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ),
        "patientId": _patientId,
      });

      final response = await _dio.post(
        "http://localhost:8080/api/patient/reports/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = "Report uploaded successfully!";
          _selectedFile = null;
        });
      } else {
        setState(() {
          _message =
              "Failed to upload report. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error uploading report: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Report"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 80, color: Colors.green[700]),
                SizedBox(height: 24),
                Text(
                  "Upload Your Medical Report",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Please select a file to upload. Supported formats are PDF, JPG, and PNG.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                if (_selectedFile == null)
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: Icon(Icons.folder_open),
                    label: Text("Select File"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file),
                      title: Text(_selectedFile!.name),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                          });
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 24),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _selectedFile != null ? _uploadFile : null,
                    child: Text("Upload Report"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFile != null
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.contains("success")
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
