import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportHistoryPage extends StatefulWidget {
  final Dio dio;
  final int patientId;

  const ReportHistoryPage({
    super.key,
    required this.dio,
    required this.patientId,
  });

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final response = await widget.dio.get(
        'http://localhost:8080/api/patient/reports/patient/${widget.patientId}',
      );
      setState(() {
        reports = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load reports')));
    }
  }

  Future<void> openReport(Map<String, dynamic> report) async {
    // If blob url available, use that
    final String url =
        report['fileUrl'] ??
        "http://localhost:8080/uploads/${report['fileName']}";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open report')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text('No reports found'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      report['fileType'] == "application/pdf"
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: report['fileType'] == "application/pdf"
                          ? Colors.red
                          : Colors.blue,
                    ),
                    title: Text(report['originalName'] ?? 'Unknown'),
                    subtitle: Text(
                      '${report['category'] ?? 'No category'}\nUploaded: ${report['uploadedAt'] ?? ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => openReport(report),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
