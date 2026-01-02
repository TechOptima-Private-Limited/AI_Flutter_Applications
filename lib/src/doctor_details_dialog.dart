// lib/widgets/doctor_details_dialog.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class DoctorDetailsDialog extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsDialog({super.key, required this.doctorId});

  @override
  State<DoctorDetailsDialog> createState() => _DoctorDetailsDialogState();
}

class _DoctorDetailsDialogState extends State<DoctorDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _specializationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _specializationCtrl.dispose();
    _experienceCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  // lib/widgets/doctor_details_dialog.dart

  // lib/widgets/doctor_details_dialog.dart

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final api = ApiService();

      final specialization = _specializationCtrl.text.trim();
      final experienceYears = int.tryParse(_experienceCtrl.text.trim()) ?? 0;
      final about = _aboutCtrl.text.trim();

      debugPrint('='.padRight(60, '='));
      debugPrint('📝 SAVING DOCTOR PROFILE');
      debugPrint('   Specialization: $specialization');
      debugPrint('   Experience: $experienceYears years');
      debugPrint('   About: $about');
      debugPrint('='.padRight(60, '='));

      // Step 1: Save to backend
      await api.updateDoctorProfile(
        specialization: specialization,
        experienceYears: experienceYears,
        about: about.isEmpty ? null : about,
      );

      // Step 2: Wait for backend to finish
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Force fetch fresh data
      debugPrint('🔄 Fetching fresh data from /users/me...');
      await SessionService.instance.fetchMe(api);

      if (!mounted) return;

      debugPrint('✅ PROFILE SAVED SUCCESSFULLY');
      debugPrint('='.padRight(60, '='));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('❌ ERROR SAVING PROFILE: $e');
      debugPrint('='.padRight(60, '='));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.blue.shade700, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Complete Your Profile',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Help patients know more about you',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Specialization field
                TextFormField(
                  controller: _specializationCtrl,
                  decoration: InputDecoration(
                    labelText: 'Specialization *',
                    hintText: 'e.g., Cardiology, Pediatrics',
                    prefixIcon: const Icon(Icons.medical_services),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Experience field
                TextFormField(
                  controller: _experienceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Years of Experience *',
                    hintText: 'e.g., 5',
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final num = int.tryParse(v.trim());
                    if (num == null) return 'Enter a valid number';
                    if (num < 0 || num > 70) return 'Enter 0-70 years';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // About field
                TextFormField(
                  controller: _aboutCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'About You (Optional)',
                    hintText: 'Tell patients about your expertise and approach...',
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Skip for now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
