import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../constants/api_constants.dart';

void main() => runApp(const EhikmatDoctorApp());

//──────────────────────────────────────── APP ROOT ────
class EhikmatDoctorApp extends StatelessWidget {
  const EhikmatDoctorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E‑Hikmat Doctor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DoctorFormScreen(),
    );
  }
}

//────────────────────────────────────── FORM SCREEN ────
class DoctorFormScreen extends StatefulWidget {
  const DoctorFormScreen({super.key});

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // ── Form state containers ──
  final Map<String, dynamic> profile = {
    "secondary_specialization": <String>[],
    "services": <String>[],
    "conditions_treated": <String>[],
    "clinics": <Map<String, dynamic>>[],
    "education_records": <Map<String, dynamic>>[],
    "experience_records": <Map<String, dynamic>>[],
    "video_consultation": {
      "is_available": true,
      "timings": '',
      "days": '',
      "duration_minutes": 0,
      "fees": 0,
    },
    "agreement": false,
    "representative_names": '',
  };

  // ── Look‑up lists ──
  final cities = [
    'Lahore', 'Karachi', 'Islamabad', 'Multan', 'Faisalabad', 'Rawalpindi', 'Quetta', 'Peshawar'
  ];
  final genders = ['Male', 'Female', 'Other'];
  final specialisations = [
    {'key': 'general_tibb', 'label': 'General Tibb'},
    {'key': 'hijama', 'label': 'Hijama'},
    {'key': 'nutrition', 'label': 'Nutrition'},
    {'key': 'cupping', 'label': 'Cupping'},
    {'key': 'spiritual_healing', 'label': 'Spiritual Healing'},
    {'key': 'herbal', 'label': 'Herbal Medicine'},
  ];
  final servicesList = [
    {'key': 'cupping_therapy', 'label': 'Cupping Therapy'},
    {'key': 'herbal_consultation', 'label': 'Herbal Consultation'},
    {'key': 'diet_plan', 'label': 'Diet Plan'},
    {'key': 'pain_management', 'label': 'Pain Management'},
  ];
  final conditionsList = [
    'Back Pain',
    'Migraine',
    'Diabetes',
    'Blood Pressure',
    'Infertility',
  ];
  final countries = ['Pakistan', 'India', 'UAE', 'USA', 'UK', 'Afghanistan', 'Iran'];
  final degrees = ['BEMS', 'DUMS', 'FTJ', 'RHMP'];

  // ── Helpers ──
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  void _continue() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _cancel() =>
      setState(() => _currentStep = _currentStep > 0 ? _currentStep - 1 : 0);

  //────────────────────────────── SUBMIT ────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // encode image
    if (_profileImage != null) {
      final bytes = await _profileImage!.readAsBytes();
      profile['profile_image'] =
          'data:image/jpeg;base64,${base64Encode(bytes)}';
    }

    // agreement check
    if (!(profile['agreement'] ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the agreement.')),
      );
      return;
    }

    // ── Debug log: request ──
    debugPrint('📤 Sending payload to API →');
    debugPrint(const JsonEncoder.withIndent('  ').convert(profile));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.doctorProfile),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profile),
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      // ── Debug log: response ──
      debugPrint('📥 Response status: ${res.statusCode}');
      debugPrint('📥 Response body:${res.body}');

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(res.statusCode == 200 || res.statusCode == 201 ? 'Profile Submitted' : 'Submission Error'),
          content: SingleChildScrollView(child: Text('Status: ${res.statusCode}\nBody: ${res.body}')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      debugPrint('❌ Network exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error → $e')));
    }
  }

  //────────────────────────────── BUILD STEPS ────
  List<Step> _buildSteps() => [
    // 0 ── Basic Info ────────────────────────────
    Step(
      title: const Text('Basic'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Choose Photo'),
              ),
            ],
          ),
          _text(
            'Full Name *',
            save: (v) => profile['full_name'] = v,
            required: true,
          ),
          _text(
            'Phone *',
            save: (v) => profile['phone'] = v,
            kb: TextInputType.phone,
            required: true,
          ),
          _text(
            'Email *',
            save: (v) => profile['email'] = v,
            kb: TextInputType.emailAddress,
            requiredEmail: true,
          ),
          _dropdown(
            'Gender *',
            genders.map((e) => e.toLowerCase()).toList(),
            save: (v) => profile['gender'] = v,
          ),
          _dropdown('City *', cities, save: (v) => profile['city'] = v),
        ],
      ),
    ),

    // 1 ── Specialisation ─────────────────────────
    Step(
      title: const Text('Specialisation'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          _dropdown(
            'Primary *',
            specialisations
                .map((s) => s['key'] as String)
                .toList(),
            labels: specialisations.map((s) => s['label'] as String).toList(),
            save: (v) => profile['primary_specialization'] = v,
          ),
          const SizedBox(height: 8),
          MultiSelectDialogField<String>(
            buttonText: const Text('Secondary Specialisations'),
            title: const Text('Secondary Specialisations'),
            items: specialisations
                .map(
                  (s) =>
                      MultiSelectItem(s['key'] as String, s['label'] as String),
                )
                .toList(),
            onConfirm: (vals) => profile['secondary_specialization'] = vals,
          ),
          _text(
            'Experience Years',
            kb: TextInputType.number,
            save: (v) =>
                profile['experience_years'] = int.tryParse(v ?? '0') ?? 0,
          ),
          _text(
            'NCT Registration No',
            save: (v) => profile['nct_registration_no'] = v,
          ),
          _text(
            'Other Accreditation',
            save: (v) => profile['other_accreditation'] = v,
          ),
        ],
      ),
    ),

    // 2 ── Clinics ────────────────────────────────
    Step(
      title: const Text('Clinics'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          ...profile['clinics'].asMap().entries.map(
            (e) => _clinicCard(e.key, e.value),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => setState(
                () => profile['clinics'].add({
                  'name': '',
                  'address': '',
                  'phone': '',
                  'assistant_cell': '',
                  'practicing_since': DateTime.now().year,
                  'timings': '',
                  'days': '',
                  'fees': 0,
                  'region': '',
                }),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Clinic'),
            ),
          ),
        ],
      ),
    ),

    // 3 ── Video Consultation ─────────────────────
    Step(
      title: const Text('Video Consult'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          SwitchListTile(
            value: profile['video_consultation']['is_available'] as bool,
            onChanged: (v) => setState(
              () => profile['video_consultation']['is_available'] = v,
            ),
            title: const Text('Available?'),
          ),
          _text(
            'Timings',
            save: (v) => profile['video_consultation']['timings'] = v,
          ),
          _text('Days', save: (v) => profile['video_consultation']['days'] = v),
          _text(
            'Duration minutes',
            kb: TextInputType.number,
            save: (v) => profile['video_consultation']['duration_minutes'] =
                int.tryParse(v ?? '0') ?? 0,
          ),
          _text(
            'Fees',
            kb: TextInputType.number,
            save: (v) => profile['video_consultation']['fees'] =
                int.tryParse(v ?? '0') ?? 0,
          ),
        ],
      ),
    ),

    // 4 ── Education ──────────────────────────────
    Step(
      title: const Text('Education'),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          ...profile['education_records'].asMap().entries.map(
            (e) => _educationCard(e.key, e.value),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => setState(
                () => profile['education_records'].add({
                  'degree': '',
                  'institute': '',
                  'country': '',
                  'start_year': DateTime.now().year,
                  'end_year': DateTime.now().year,
                }),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Education'),
            ),
          ),
        ],
      ),
    ),

    // 5 ── Experience ─────────────────────────────
    Step(
      title: const Text('Experience'),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          ...profile['experience_records'].asMap().entries.map(
            (e) => _experienceCard(e.key, e.value),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => setState(
                () => profile['experience_records'].add({
                  'position': '',
                  'clinic_or_hospital': '',
                  'country': '',
                  'start_year': DateTime.now().year,
                  'end_year': DateTime.now().year,
                }),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Experience'),
            ),
          ),
        ],
      ),
    ),

    // 6 ── Services & Conditions ──────────────────
    Step(
      title: const Text('Services'),
      isActive: _currentStep >= 6,
      state: _currentStep > 6 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          MultiSelectDialogField<String>(
            buttonText: const Text('Services'),
            title: const Text('Services Provided'),
            items: servicesList
                .map(
                  (s) => MultiSelectItem<String>(s['key'] as String, s['label'] as String),
                )
                .toList(),
            onConfirm: (vals) => profile['services'] = vals,
          ),
          const SizedBox(height: 8),
          MultiSelectDialogField<String>(
            buttonText: const Text('Conditions Treated'),
            title: const Text('Conditions'),
            items: conditionsList
                .map(
                  (c) =>
                      MultiSelectItem(c.toLowerCase().replaceAll(' ', '_'), c),
                )
                .toList(),
            onConfirm: (vals) => profile['conditions_treated'] = vals,
          ),
        ],
      ),
    ),

    // 7 ── Agreement & Submit ─────────────────────
    Step(
      title: const Text('Agreement'),
      isActive: _currentStep >= 7,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📢 Disclaimer – E-Hikmat App\n\nIf you have given any amount of money to an E-Hikmat representative, please contact our Accounts Department immediately.\n\nYou confirm that you are not involved in any illegal or unethical activities.',
            style: TextStyle(fontSize: 13),
          ),
          CheckboxListTile(
            value: profile['agreement'] ?? false,
            onChanged: (v) => setState(() => profile['agreement'] = v),
            title: const Text(
              '✔ I confirm all details provided are authentic.',
            ),
          ),
          _text(
            'Representative Names',
            save: (v) => profile['representative_names'] = v,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send),
            label: const Text('Submit Form'),
          ),
        ],
      ),
    ),
  ];

  //───────────────────────── WIDGET UTILITIES ────
  Widget _text(
    String label, {
    TextInputType kb = TextInputType.text,
    FormFieldSetter<String>? save,
    bool required = false,
    bool requiredEmail = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: kb,
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) return 'Required';
        if (requiredEmail && (v == null || !v.contains('@')))
          return 'Invalid email';
        return null;
      },
      onSaved: save,
    );
  }

  Widget _dropdown(
    String label,
    List<String> values, {
    List<String>? labels,
    FormFieldSetter<String>? save,
  }) {
    labels ??= values;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: List.generate(
        values.length,
        (i) => DropdownMenuItem(value: values[i], child: Text(labels![i])),
      ),
      validator: (v) => v == null ? 'Required' : null,
      onChanged: (_) {},
      onSaved: save,
    );
  }

  Widget _clinicCard(int idx, Map<String, dynamic> clinic) => Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _text('Name', save: (v) => clinic['name'] = v),
          _text('Address', save: (v) => clinic['address'] = v),
          _text(
            'Phone',
            kb: TextInputType.phone,
            save: (v) => clinic['phone'] = v,
          ),
          _text(
            'Assistant Cell',
            kb: TextInputType.phone,
            save: (v) => clinic['assistant_cell'] = v,
          ),
          _text(
            'Practicing Since',
            kb: TextInputType.number,
            save: (v) =>
                clinic['practicing_since'] = int.tryParse(v ?? '0') ?? 0,
          ),
          _text('Timings', save: (v) => clinic['timings'] = v),
          _text('Days', save: (v) => clinic['days'] = v),
          _text(
            'Fees',
            kb: TextInputType.number,
            save: (v) => clinic['fees'] = int.tryParse(v ?? '0') ?? 0,
          ),
          _text('Region', save: (v) => clinic['region'] = v),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => profile['clinics'].removeAt(idx)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _educationCard(int idx, Map<String, dynamic> edu) => Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _dropdown(
            'Degree',
            degrees,
            save: (v) => edu['degree'] = v,
            labels: degrees,
          ),
          _text('Institute', save: (v) => edu['institute'] = v),
          _dropdown('Country', countries, save: (v) => edu['country'] = v),
          _text(
            'Start Year',
            kb: TextInputType.number,
            save: (v) => edu['start_year'] = int.tryParse(v ?? '0') ?? 0,
          ),
          _text(
            'End Year',
            kb: TextInputType.number,
            save: (v) => edu['end_year'] = int.tryParse(v ?? '0') ?? 0,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  setState(() => profile['education_records'].removeAt(idx)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _experienceCard(int idx, Map<String, dynamic> exp) => Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _text('Position', save: (v) => exp['position'] = v),
          _text('Clinic/Hospital', save: (v) => exp['clinic_or_hospital'] = v),
          _dropdown('Country', countries, save: (v) => exp['country'] = v),
          _text(
            'Start Year',
            kb: TextInputType.number,
            save: (v) => exp['start_year'] = int.tryParse(v ?? '0') ?? 0,
          ),
          _text(
            'End Year',
            kb: TextInputType.number,
            save: (v) => exp['end_year'] = int.tryParse(v ?? '0') ?? 0,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  setState(() => profile['experience_records'].removeAt(idx)),
            ),
          ),
        ],
      ),
    ),
  );

  //────────────────────────────────── BUILD ────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Registration')),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _continue,
          onStepCancel: _cancel,
          steps: _buildSteps(),
        ),
      ),
    );
  }
}
