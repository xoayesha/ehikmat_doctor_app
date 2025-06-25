import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/doctor_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Hikmat Doctor App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DoctorFormScreen(),
    );
  }
}
