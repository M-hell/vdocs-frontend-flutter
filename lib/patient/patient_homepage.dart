import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_widgets.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late final Dio _dio;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;

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
        "http://localhost:8080/api/patient/auth/me",
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

  Widget _buildHeader() {
    if (_patientData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.white.withOpacity(0.2),
                child: const Icon(
                  Iconsax.user,
                  size: 32,
                  color: AppTheme.white,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withOpacity(0.8),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _patientData!['name'] ?? 'Patient',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(
                  Iconsax.logout,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          const Gap(20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: AppTheme.white,
                  size: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Your health journey starts here. Access all your medical services in one place.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Quick Overview',
            subtitle: 'Your health statistics at a glance',
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  child: SlideAnimation(
                    horizontalOffset: -50,
                    child: FadeInAnimation(
                      child: StatCard(
                        icon: Iconsax.calendar,
                        title: 'Appointments',
                        value: '3',
                        iconColor: AppTheme.info,
                        onTap: () => _onBottomNavTap(1),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: AnimationConfiguration.staggeredList(
                  position: 1,
                  child: SlideAnimation(
                    horizontalOffset: 50,
                    child: FadeInAnimation(
                      child: StatCard(
                        icon: Iconsax.document,
                        title: 'Reports',
                        value: '8',
                        iconColor: AppTheme.success,
                        onTap: () => _onBottomNavTap(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Quick Actions',
            subtitle: 'Manage your health needs',
          ),
          const Gap(8),
          AnimationConfiguration.staggeredList(
            position: 0,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.calendar_add,
                  title: 'Book Appointment',
                  subtitle: 'Schedule your next consultation',
                  iconColor: AppTheme.primaryBlue,
                  onTap: () {
                    _showComingSoonDialog('Book Appointment');
                  },
                ),
              ),
            ),
          ),
          const Gap(12),
          AnimationConfiguration.staggeredList(
            position: 1,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.document_upload,
                  title: 'Upload Report',
                  subtitle: 'Add your medical reports',
                  iconColor: AppTheme.success,
                  onTap: () {
                    _showComingSoonDialog('Upload Report');
                  },
                ),
              ),
            ),
          ),
          const Gap(12),
          AnimationConfiguration.staggeredList(
            position: 2,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.calendar_tick,
                  title: 'My Appointments',
                  subtitle: 'View and manage appointments',
                  iconColor: AppTheme.info,
                  onTap: () {
                    _showComingSoonDialog('My Appointments');
                  },
                ),
              ),
            ),
          ),
          const Gap(12),
          AnimationConfiguration.staggeredList(
            position: 3,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.folder_open,
                  title: 'Report History',
                  subtitle: 'Access your medical records',
                  iconColor: AppTheme.warning,
                  onTap: () {
                    _showComingSoonDialog('Report History');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.info_circle,
              color: AppTheme.primaryBlue,
            ),
            const Gap(8),
            const Text('Coming Soon'),
          ],
        ),
        content: Text('$feature feature will be available soon!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.logout,
              color: AppTheme.error,
            ),
            const Gap(8),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home - do nothing, already here
        break;
      case 1: // Appointments
        _showComingSoonDialog('Appointments');
        break;
      case 2: // Reports
        _showComingSoonDialog('Reports');
        break;
      case 3: // Profile
        _showComingSoonDialog('Profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                    const Gap(16),
                    Text(
                      'Loading your dashboard...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.lightGrey,
        body: Center(
          child: EmptyState(
            icon: Iconsax.warning_2,
            title: 'Something went wrong',
            subtitle: _errorMessage!,
            action: ElevatedButton.icon(
              onPressed: _fetchPatientData,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchPatientData,
          color: AppTheme.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: AnimationLimiter(
              child: Column(
                children: [
                  _buildHeader(),
                  const Gap(8),
                  _buildQuickStats(),
                  const Gap(24),
                  _buildQuickActions(),
                  const Gap(24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}