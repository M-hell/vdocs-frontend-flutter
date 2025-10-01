import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_widgets.dart';

class PatientLoginPage extends StatefulWidget {
  @override
  _PatientLoginPageState createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final Dio _dio;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio();

    if (kIsWeb) {
      _dio.options.extra['withCredentials'] = true;
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.post(
        "http://localhost:8080/api/patient/auth/login",
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(
          context,
          '/patient-home',
          arguments: _dio,
        );
      } else {
        setState(() {
          _errorMessage = "Invalid credentials. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed. Please check your connection and try again.";
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
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
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
                        const SizedBox(height: 24),
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your patient account',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Login Form
              AnimationConfiguration.staggeredList(
                position: 1,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: CustomCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            CustomTextField(
                              label: 'Email Address',
                              hint: 'Enter your email',
                              controller: _emailController,
                              prefixIcon: Iconsax.sms,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Password Field
                            CustomTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              prefixIcon: Iconsax.lock,
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Error Message
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.warning_2,
                                      color: AppTheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Login Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SpinKitThreeBounce(
                                        color: AppTheme.white,
                                        size: 20,
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Iconsax.login),
                                          const SizedBox(width: 8),
                                          const Text('Sign In'),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Register Link
              AnimationConfiguration.staggeredList(
                position: 2,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/patient-register');
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}