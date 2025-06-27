import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'doctor_form_screen.dart';

String formatPhone(String phone) {
  phone = phone.trim();
  if (phone.startsWith('+92 ')) {
    // Ensure space after +92
    if (phone.length > 3 && phone[3] != ' ') {
      phone = '+92 ' + phone.substring(3);
    }
    return phone;
  }
  // Remove leading 0 if present
  if (phone.startsWith('0')) phone = phone.substring(1);
  return '+92 $phone';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;

  void _sendOtp() async {
    setState(() => _loading = true);
    String phone = formatPhone(_phoneController.text);
    final success = await AuthService.sendOtp(phone);
    setState(() => _loading = false);
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+92 ',
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendOtp,
                    child: const Text('Send OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;

  void _verifyOtp() async {
    setState(() => _loading = true);
    final code = _otpController.text.trim();
    final result = await AuthService.verifyOtp(widget.phone, code);
    setState(() => _loading = false);
    print('Verify OTP result:');
    print(result);
    if (result['success']) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Token Generated'),
          content: SingleChildScrollView(child: Text(result['token'].toString() + '\n' + result['response'].toString())),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorFormScreen()),
                  (route) => false,
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('OTP Verification Failed'),
          content: SingleChildScrollView(child: Text(result['error'].toString() + '\n' + result['response'].toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('OTP sent to ${widget.phone}'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('Verify OTP'),
                  ),
          ],
        ),
      ),
    );
  }
} 