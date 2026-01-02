// lib/src/doctor_onboarding_guard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';
import 'doctor_details_dialog.dart';
import 'doctor_dashboard.dart';
import 'select_hospital_page.dart';

class DoctorOnboardingGuard extends StatefulWidget {
  const DoctorOnboardingGuard({super.key});

  @override
  State<DoctorOnboardingGuard> createState() => _DoctorOnboardingGuardState();
}

class _DoctorOnboardingGuardState extends State<DoctorOnboardingGuard> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  bool _needsHospital(Map<String, dynamic> u) {
    final hasHospitalId = u['selected_hospital_id'] != null;
    final hasHospitalName = (u['selected_hospital_name'] ?? '').toString().trim().isNotEmpty;
    final hasHospitalObj = u['hospital'] is Map<String, dynamic>;
    return !(hasHospitalId || hasHospitalName || hasHospitalObj);
  }

  bool _needsDoctorDetails(Map<String, dynamic> u) {
    final spec = (u['specialization'] ?? '').toString().trim();
    final exp = u['experience_years'];
    final expNum = exp is num ? exp : num.tryParse(exp?.toString() ?? '');
    final hasSpec = spec.isNotEmpty;
    final hasExp = (expNum ?? 0) > 0;
    return !(hasSpec && hasExp);
  }

  Future<void> _run() async {
    try {
      final session = context.read<SessionService>();

      // Always refresh once so session has latest joined fields
      await session.fetchMe(_api);

      final user = session.user;
      if (user == null) {
        throw Exception('Session user is null');
      }

      // 1) Hospital selection if missing
      if (_needsHospital(user)) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SelectHospitalPage()),
        );
        return;
      }

      // 2) Doctor details dialog if missing
      if (_needsDoctorDetails(user)) {
        if (!mounted) return;

        final doctorId = user['id']?.toString() ?? '';
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => DoctorDetailsDialog(doctorId: doctorId),
        );

        // refresh after dialog save/skip
        await session.fetchMe(_api);
      }

      // 3) Go to dashboard
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DoctorDashboard()),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple loader screen while deciding
    return Scaffold(
      body: Center(
        child: _error != null
            ? Text('Error: $_error')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
