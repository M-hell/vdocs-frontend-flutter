import 'package:flutter/material.dart';
import 'login_page.dart';
import 'clinic/clinic_login_page.dart';
import 'clinic/clinic_homepage.dart';
import 'patient/patient_login_page.dart';
import 'patient/patient_homepage.dart';
import 'patient/report_upload_page.dart';
import 'patient/patient_register.dart';
import 'clinic/clinic_register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/clinic-login': (context) => ClinicLoginPage(),
        '/clinic-home': (context) => ClinicHomePage(),
        '/patient-login': (context) => PatientLoginPage(),
        '/patient-home': (context) => PatientHomePage(),
        '/uploadReport': (context) => ReportUploadPage(),
        '/patient-register': (context) => PatientRegisterPage(),
        '/clinic-register': (context) => ClinicRegisterPage(),
      },
    );
  }
}
