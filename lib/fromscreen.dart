import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class DoctorRegistrationUI extends StatefulWidget {
  const DoctorRegistrationUI({super.key});

  @override
  State<DoctorRegistrationUI> createState() => _DoctorRegistrationUIState();
}

class _DoctorRegistrationUIState extends State<DoctorRegistrationUI> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  List<String> cities = ['Lahore', 'Karachi', 'Islamabad', 'Peshawar'];
  List<String> genders = ['Male', 'Female', 'Other'];
  List<String> degrees = ['BEMS', 'MD (Tibb)', 'Fellowship'];
  List<String> countries = ['Pakistan', 'UK', 'USA', 'UAE', 'India'];
  List<String> specializations = [
    'General Tibb',
    'Skin',
    'Women Health',
    'Mental Health'
  ];
  List<String> services = ['Herbal Treatment', 'Cupping', 'Counseling'];
  List<String> conditions = ['Acne', 'Diabetes', 'Arthritis', 'Flu'];

  Future<void> _pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _nextStep() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() => _currentStep += 1);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Basic Info"),
        isActive: _currentStep >= 0,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Upload Profile"),
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Personal Cell"),
              keyboardType: TextInputType.phone,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Gender"),
              items: genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (_) {},
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "City"),
              items: cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (_) {},
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Specializations"),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Primary Specialization"),
              items: specializations
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 10),
            MultiSelectDialogField<String>(
              title: const Text("Select Secondary Specializations"),
              buttonText: const Text("Secondary Specializations"),
              items: specializations
                  .map((s) => MultiSelectItem(s, s))
                  .toList(),
              onConfirm: (values) {},
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Education"),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Degree"),
              items: degrees
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (_) {},
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Country"),
              items: countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (_) {},
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Institute"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: "Start Year"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: "End Year"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Video Consultation"),
        isActive: _currentStep >= 3,
        content: Column(
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: "VC Timings (e.g. 5pm - 8pm)"),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "VC Appointment Duration (10-60 min)"),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "VC Fees"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Services & Conditions"),
        isActive: _currentStep >= 4,
        content: Column(
          children: [
            MultiSelectDialogField<String>(
              title: const Text("Select Services"),
              buttonText: const Text("Services Provided"),
              items: services.map((s) => MultiSelectItem(s, s)).toList(),
              onConfirm: (values) {},
            ),
            const SizedBox(height: 10),
            MultiSelectDialogField<String>(
              title: const Text("Select Conditions"),
              buttonText: const Text("Conditions Treated"),
              items: conditions.map((c) => MultiSelectItem(c, c)).toList(),
              onConfirm: (values) {},
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Agreement"),
        isActive: _currentStep >= 5,
        content: Column(
          children: const [
            Text(
              "📢 Disclaimer – E-Hikmat App\n\nIf you have given any amount of money to an E-Hikmat representative, please contact our Accounts Department immediately.\n\nYou confirm that you are not involved in any illegal or unethical activities.",
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 10),
            Text("✔ I confirm all details provided are authentic.")
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Registration"),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _prevStep,
          steps: _buildSteps(),
        ),
      ),
    );
  }
}
