import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Appointement/ClinicAppointmentDetailPage.dart';

class ClinicAppointmentsPage extends StatefulWidget {
  final Dio dio;

  const ClinicAppointmentsPage({super.key, required this.dio});

  @override
  _ClinicAppointmentsPageState createState() => _ClinicAppointmentsPageState();
}

class _ClinicAppointmentsPageState extends State<ClinicAppointmentsPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _appointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Tab controller for filter tabs
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Available status filters
  final List<String> _statusFilters = ['CONFIRMED', 'PENDING', 'CANCELLED'];
  final Map<String, String> _statusDisplayNames = {
    'CONFIRMED': 'Confirmed',
    'PENDING': 'Pending',
    'CANCELLED': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _filterAppointments();
      });
    }
  }

  void _filterAppointments() {
    final selectedStatus = _statusFilters[_currentTabIndex];
    setState(() {
      _filteredAppointments = _appointments
          .where((appt) => appt['status'] == selectedStatus)
          .toList();
    });
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
        _filterAppointments();
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
      case 'CONFIRMED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Custom empty state animation widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Custom animated empty state
          _EmptyStateAnimation(status: _statusFilters[_currentTabIndex]),
          const SizedBox(height: 24),
          Text(
            "No ${_statusDisplayNames[_statusFilters[_currentTabIndex]]?.toLowerCase()} appointments",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try a different filter or check back later",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ColoredBox(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor:
                  Colors.white, // Set the color of the selected tab's label
              unselectedLabelColor: Colors.white.withOpacity(
                0.7,
              ), // Set the color of the unselected tabs
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: _statusFilters
                  .map((status) => Tab(text: _statusDisplayNames[status]))
                  .toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
              children: [
                Expanded(
                  child: _filteredAppointments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _filteredAppointments[index];
                            final clinicName =
                                appointment['clinic']?['name'] ??
                                'Unknown Clinic';
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
                                leading: Container(
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  "${appointment['patientName']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      "Clinic: $clinicName",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Date: $date",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Medical Requirement: $medicalRequirement",
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ClinicAppointmentDetailPage(
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAppointments,
        child: const Icon(Icons.refresh),
        mini: true,
      ),
    );
  }
}

// Custom animated empty state widget
class _EmptyStateAnimation extends StatefulWidget {
  final String status;

  const _EmptyStateAnimation({required this.status});

  @override
  __EmptyStateAnimationState createState() => __EmptyStateAnimationState();
}

class __EmptyStateAnimationState extends State<_EmptyStateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.access_time;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getStatusIconColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blue;
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
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _getStatusIconColor(widget.status).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStatusIcon(widget.status),
          size: 60,
          color: _getStatusIconColor(widget.status),
        ),
      ),
    );
  }
}
