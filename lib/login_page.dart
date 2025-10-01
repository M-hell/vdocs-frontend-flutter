import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/custom_widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Gap(40),
              
              // Header Section
              AnimationConfiguration.staggeredList(
                position: 0,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.hospital,
                            size: 48,
                            color: AppTheme.white,
                          ),
                        ),
                        const Gap(24),
                        Text(
                          'VDocs',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Your Digital Health Companion',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Select your login type to continue',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Gap(48),
              
              // Login Options
              AnimationConfiguration.staggeredList(
                position: 1,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Column(
                      children: [
                        // Patient Login Card
                        ActionCard(
                          icon: Iconsax.user,
                          title: 'Patient Login',
                          subtitle: 'Access your health records and appointments',
                          iconColor: AppTheme.primaryBlue,
                          onTap: () {
                            Navigator.pushNamed(context, '/patient-login');
                          },
                        ),
                        
                        const Gap(16),
                        
                        // Clinic Login Card
                        ActionCard(
                          icon: Iconsax.hospital,
                          title: 'Clinic Login',
                          subtitle: 'Manage appointments and patient records',
                          iconColor: AppTheme.success,
                          onTap: () {
                            Navigator.pushNamed(context, '/clinic-login');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Gap(48),
              
              // Features Section
              AnimationConfiguration.staggeredList(
                position: 2,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: CustomCard(
                      child: Column(
                        children: [
                          Text(
                            'Why Choose VDocs?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const Gap(16),
                          _buildFeature(
                            context,
                            Iconsax.shield_tick,
                            'Secure & Private',
                            'Your data is protected with industry-standard security',
                          ),
                          const Gap(12),
                          _buildFeature(
                            context,
                            Iconsax.clock,
                            '24/7 Access',
                            'Access your health information anytime, anywhere',
                          ),
                          const Gap(12),
                          _buildFeature(
                            context,
                            Iconsax.document,
                            'Digital Records',
                            'Keep all your medical records in one place',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}