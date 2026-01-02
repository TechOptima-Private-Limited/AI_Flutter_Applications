// lib/src/services/location_service.dart
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<geo.LocationPermission> checkPermission() async {
    return await geo.Geolocator.checkPermission();
  }

  // Request location permission
  Future<geo.LocationPermission> requestPermission() async {
    return await geo.Geolocator.requestPermission();
  }

  // Get current location as Mapbox Position (lng, lat)
  Future<Position> getCurrentLocation() async {
    try {
      var permission = await checkPermission();

      if (permission == geo.LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == geo.LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Position constructor is (lng, lat)
      return Position(pos.longitude, pos.latitude);
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  // Stream location updates as Position
  Stream<Position> getLocationStream() {
    const locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 10, // meters
    );

    return geo.Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((pos) => Position(pos.longitude, pos.latitude));
  }

  // Calculate distance between two Positions (km, Haversine)
  double calculateDistance(Position from, Position to) {
    const earthRadiusKm = 6371.0;

    double toRad(double deg) => deg * pi / 180;

    final fromLat = from.lat.toDouble();
    final fromLng = from.lng.toDouble();
    final toLat = to.lat.toDouble();
    final toLng = to.lng.toDouble();

    final dLat = toRad(toLat - fromLat);
    final dLon = toRad(toLng - fromLng);

    final lat1 = toRad(fromLat);
    final lat2 = toRad(toLat);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

}
