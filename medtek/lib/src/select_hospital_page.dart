import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/hospital.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'doctor_details_dialog.dart';
import 'doctor_onboarding_guard.dart';

class SelectHospitalPage extends StatefulWidget {
  const SelectHospitalPage({super.key});

  @override
  State<SelectHospitalPage> createState() => _SelectHospitalPageState();
}

class _SelectHospitalPageState extends State<SelectHospitalPage> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  geo.Position? _currentPosition;
  List<Hospital> _hospitals = [];
  Hospital? _selectedHospital;

  bool _loading = true;
  bool _searching = false;
  bool _saving = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _checkExistingHospital();
  }

  Future<void> _checkExistingHospital() async {
    try {
      // Use the API helper you already have.
      final myHospital = await _api.getMyHospital();

      if (myHospital != null && myHospital['hospital'] != null) {
        debugPrint('✅ Doctor already has hospital selected -> go to Guard');

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DoctorOnboardingGuard()),
        );
        return;
      }

      debugPrint('⚠️ No hospital selected, showing selection screen');
      await _initLocation();
    } catch (e) {
      debugPrint('Check hospital error: $e');
      await _initLocation();
    }
  }

  Future<void> _initLocation() async {
    geo.Position fallback() => geo.Position(
      latitude: 17.3850,
      longitude: 78.4867,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentPosition = fallback();
          _loading = false;
        });
        return;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.deniedForever ||
          permission == geo.LocationPermission.denied) {
        setState(() {
          _currentPosition = fallback();
          _loading = false;
        });
        return;
      }

      final pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = pos;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Location error: $e');
      setState(() {
        _currentPosition = fallback();
        _loading = false;
      });
    }
  }

  Future<void> _searchHospitals(String query) async {
    if (query.isEmpty || _currentPosition == null) return;

    setState(() {
      _searching = true;
      _hospitals = [];
      _selectedHospital = null;
    });

    try {
      final results = await _api.searchHospitals(
        query: query,
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );

      setState(() {
        _hospitals = results;
        _searching = false;
      });

      if (results.isNotEmpty) {
        await _showHospitalMarkers(results);
      }
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => _searching = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  Future<void> _showHospitalMarkers(List<Hospital> hospitals) async {
    if (_pointAnnotationManager == null) return;

    await _pointAnnotationManager!.deleteAll();

    final annotations = <PointAnnotationOptions>[];
    for (final hospital in hospitals) {
      annotations.add(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(hospital.longitude, hospital.latitude),
          ),
          iconSize: 1.5,
        ),
      );
    }

    await _pointAnnotationManager!.createMulti(annotations);

    if (hospitals.isNotEmpty) {
      final first = hospitals.first;
      await _mapboxMap?.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(first.longitude, first.latitude)),
          zoom: 14,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedHospital == null) return;

    setState(() => _saving = true);

    try {
      // 1) Save hospital selection (address omitted because Hospital has no address)
      await _api.selectHospitalForDoctor({
        'google_place_id': _selectedHospital!.id,
        'name': _selectedHospital!.name,
        'city': 'India',
        'latitude': _selectedHospital!.latitude,
        'longitude': _selectedHospital!.longitude,
      });

      debugPrint('✅ Hospital selection saved');

      if (!mounted) return;

      // 2) Doctor details dialog (optional, guard will re-check anyway)
      final session = context.read<SessionService>();
      final doctorId = session.user?['id']?.toString() ?? '';

      if (doctorId.isNotEmpty) {
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => DoctorDetailsDialog(doctorId: doctorId),
        );
      }

      // 3) Refresh /users/me so guard reads latest values
      await session.fetchMe(_api);

      if (!mounted) return;

      // 4) Single navigation: ALWAYS go through guard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DoctorOnboardingGuard()),
            (_) => false,
      );
    } catch (e) {
      debugPrint('Confirm error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 16),
              Text('Checking hospital selection...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Hospital'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search hospital by name',
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      suffixIcon: _searching
                          ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        ),
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    onSubmitted: _searchHospitals,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                  _searching ? null : () => _searchHospitals(_searchCtrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MapWidget(
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(
                        _currentPosition!.longitude,
                        _currentPosition!.latitude,
                      ),
                    ),
                    zoom: 12,
                  ),
                  styleUri: MapboxStyles.MAPBOX_STREETS,
                  onMapCreated: (mapboxMap) async {
                    _mapboxMap = mapboxMap;
                    _pointAnnotationManager =
                    await mapboxMap.annotations.createPointAnnotationManager();
                  },
                ),
                if (_hospitals.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _selectedHospital != null ? 120 : 0,
                    child: Container(
                      height: 150,
                      color: Colors.white.withOpacity(0.95),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: _hospitals.length,
                        itemBuilder: (context, index) {
                          final hospital = _hospitals[index];
                          final isSelected = _selectedHospital?.id == hospital.id;

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedHospital = hospital);
                              _mapboxMap?.flyTo(
                                CameraOptions(
                                  center: Point(
                                    coordinates:
                                    Position(hospital.longitude, hospital.latitude),
                                  ),
                                  zoom: 15,
                                ),
                                MapAnimationOptions(duration: 800),
                              );
                            },
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red.shade50
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    hospital.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.red.shade900
                                          : Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: ${hospital.latitude.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Lng: ${hospital.longitude.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedHospital != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_hospital, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedHospital!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordinates: ${_selectedHospital!.latitude.toStringAsFixed(4)}, ${_selectedHospital!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _confirmSelection,
                      icon: _saving
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.check_circle),
                      label: Text(_saving ? 'Saving...' : 'Use this hospital'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
