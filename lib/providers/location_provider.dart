// lib/src/providers/location_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentLocation; // Mapbox Position (lng, lat)
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Position>? _locationSubscription;

  Position? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLocation = await _locationService.getCurrentLocation();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void startLocationUpdates() {
    _locationSubscription?.cancel();

    _locationSubscription = _locationService.getLocationStream().listen(
          (location) {
        _currentLocation = location;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  double? calculateDistance(Position destination) {
    if (_currentLocation == null) return null;
    return _locationService.calculateDistance(_currentLocation!, destination);
  }

  Future<bool> checkLocationService() async {
    try {
      return await _locationService.isLocationServiceEnabled();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await _locationService.requestPermission();
      return permission.toString().contains('whileInUse') ||
          permission.toString().contains('always');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
