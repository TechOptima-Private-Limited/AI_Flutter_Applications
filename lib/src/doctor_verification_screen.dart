// lib/src/doctor_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class DoctorVerificationScreen extends StatefulWidget {
  const DoctorVerificationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorVerificationScreen> createState() =>
      _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState extends State<DoctorVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _picker = ImagePicker();

  final licenseNumberController = TextEditingController();
  final authorityController = TextEditingController();
  final hospitalController = TextEditingController();
  final notesController = TextEditingController();

  List<File> documents = [];
  bool _submitting = false;
  Map<String, dynamic>? verificationStatus;
  bool _loadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final status = await _api.getVerificationStatus();
      setState(() {
        verificationStatus = status;
        _loadingStatus = false;
      });
    } catch (e) {
      setState(() => _loadingStatus = false);
    }
  }

  // Pick multiple images from gallery
  Future<void> _pickDocuments() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          documents.addAll(images.map((xFile) => File(xFile.path)).toList());
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  // Pick image from camera
  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          documents.add(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    if (documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one document')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _api.submitDoctorVerification(
        licenseNumber: licenseNumberController.text,
        authority: authorityController.text,
        hospitalAffiliation: hospitalController.text,
        notes: notesController.text,
        documents: documents,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingStatus) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Verification')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If already verified
    if (verificationStatus?['verified'] == true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Verification')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified, size: 100, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  'You are verified!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Verified on: ${verificationStatus?['request']?['reviewed_at'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If under review
    if (verificationStatus?['verification_status'] == 'under_review') {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Verification')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.pending, size: 100, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  'Verification Under Review',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'We are reviewing your documents. This may take 24-48 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Verification form
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Your Credentials',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your medical license details and upload supporting documents.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Medical License Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: authorityController,
                decoration: const InputDecoration(
                  labelText: 'License Issuing Authority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: hospitalController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Affiliation (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Upload Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload medical license, degree certificates, or ID proof (images only)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Document picker buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDocuments,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('From Gallery'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ),
                ],
              ),

              if (documents.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Selected Documents:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...documents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          doc,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      title: Text('Document ${index + 1}'),
                      subtitle: Text(
                        doc.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() => documents.removeAt(index));
                        },
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: _submitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Submit for Verification',
                    style: TextStyle(fontSize: 16),
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
    licenseNumberController.dispose();
    authorityController.dispose();
    hospitalController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
