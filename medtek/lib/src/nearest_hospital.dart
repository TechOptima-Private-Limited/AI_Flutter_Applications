// lib/src/nearest_hospital.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';

/// Simple model for normalized hospital data
class Hospital {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final Map<String, dynamic> raw;
  double? distanceKm;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.raw,
    this.distanceKm,
  });
}

/// Helper: compute Haversine distance in kilometers
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _degToRad(double deg) => deg * pi / 180.0;

/// Compute a simple lat/lon bounding box around (lat,lon) for radiusKm
Map<String, double> boundingBox(double lat, double lon, double radiusKm) {
  const latKm = 111.32;
  final latDelta = radiusKm / latKm;
  final lonDelta =
      radiusKm / (latKm * cos(_degToRad(lat)).abs().clamp(0.0001, 1.0));
  return {
    'minLat': lat - latDelta,
    'maxLat': lat + latDelta,
    'minLon': lon - lonDelta,
    'maxLon': lon + lonDelta,
  };
}

/// Nearest hospital widget using Postgres backend.
/// Expects backend endpoint:
/// GET /hospitals/nearby?lat=&lon=&radiusKm=
///   -> { hospitals: [ { id, name, address, latitude, longitude, ... } ] }
class NearestHospitalWidget extends StatefulWidget {
  final double radiusKm;
  const NearestHospitalWidget({Key? key, this.radiusKm = 10.0})
      : super(key: key);

  @override
  State<NearestHospitalWidget> createState() => _NearestHospitalWidgetState();
}

class _NearestHospitalWidgetState extends State<NearestHospitalWidget> {
  final _api = ApiService();

  Position? _position;
  String? _error;
  StreamSubscription<Position>? _posSub;
  Hospital? _nearest;
  bool _loading = true;
  bool _loadingHospitals = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services disabled.';
          _loading = false;
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission denied.';
          _loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _position = pos;
      });
      await _loadHospitals();

      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen((p) async {
        setState(() => _position = p);
        await _loadHospitals();
      }, onError: (e) {
        setState(() {
          _error = 'Location error: $e';
        });
      });
    } catch (e) {
      setState(() {
        _error = 'Location init error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadHospitals() async {
    final pos = _position;
    if (pos == null) return;

    if (_loadingHospitals) return;
    setState(() => _loadingHospitals = true);

    try {
      final res = await _api.getNearbyHospitals(
        lat: pos.latitude,
        lon: pos.longitude,
        radiusKm: widget.radiusKm,
      );

      final list =
      (res['hospitals'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

      final hospitals = list.map((data) {
        final lat =
        (data['latitude'] ?? data['lat'] ?? 0.0 as num).toDouble();
        final lon =
        (data['longitude'] ?? data['lng'] ?? data['lon'] ?? 0.0 as num)
            .toDouble();

        final h = Hospital(
          id: data['id'].toString(),
          name: (data['name'] ?? '') as String,
          address: (data['address'] ?? '') as String,
          lat: lat,
          lon: lon,
          raw: data,
        );
        h.distanceKm =
            haversineKm(pos.latitude, pos.longitude, lat, lon);
        return h;
      }).where((h) => h.lat != 0 && h.lon != 0).toList();

      hospitals.sort((a, b) =>
          (a.distanceKm ?? double.infinity)
              .compareTo(b.distanceKm ?? double.infinity));

      setState(() {
        _nearest = hospitals.isNotEmpty ? hospitals.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load hospitals: $e';
        _loading = false;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingHospitals = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_nearest == null) {
      return const Center(child: Text('No hospitals found nearby.'));
    }

    final h = _nearest!;
    final d = (h.distanceKm ?? 0).toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.teal),
        title: Text(h.name),
        subtitle: Text('${h.address}\n$d km away'),
        isThreeLine: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/hospital-detail',
            arguments: h.id,
          );
        },
      ),
    );
  }
}
