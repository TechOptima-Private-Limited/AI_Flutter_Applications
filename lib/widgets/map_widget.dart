// lib/src/widgets/map_widget.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';

class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle>? circles;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final double initialZoom;
  final MapType mapType;
  final CameraPosition? initialCameraPosition;
  final Function(CameraPosition)? onCameraMove;
  final VoidCallback? onCameraIdle;
  final bool trafficEnabled;
  final bool buildingsEnabled;

  const MapWidget({
    Key? key,
    required this.initialPosition,
    this.markers = const {},
    this.polylines = const {},
    this.circles,
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = true,
    this.initialZoom = 14.0,
    this.mapType = MapType.normal,
    this.initialCameraPosition,
    this.onCameraMove,
    this.onCameraIdle,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
    _controller = controller;
    widget.onMapCreated?.call(controller);
  }

  /// Animate camera to a specific position
  Future<void> animateToPosition(LatLng position, {double? zoom}) async {
    final controller = await _controllerCompleter.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom ?? widget.initialZoom),
    );
  }

  /// Move camera to show all markers
  Future<void> fitMarkersBounds(Set<Marker> markers) async {
    if (markers.isEmpty) return;

    final controller = await _controllerCompleter.future;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: widget.initialCameraPosition ??
          CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
      markers: widget.markers,
      polylines: widget.polylines,
      circles: widget.circles ?? {},
      onMapCreated: _onMapCreated,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapType: widget.mapType,
      onCameraMove: widget.onCameraMove,
      onCameraIdle: widget.onCameraIdle,
      trafficEnabled: widget.trafficEnabled,
      buildingsEnabled: widget.buildingsEnabled,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      mapToolbarEnabled: false,
    );
  }
}

/// Helper class for creating custom markers
class CustomMarkerHelper {
  /// Create a custom marker from an asset image
  static Future<BitmapDescriptor> createMarkerFromAsset(
      String assetPath, {
        int width = 100,
        int height = 100,
      }) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Create a pickup marker (green)
  static Marker createPickupMarker({
    required String markerId,
    required LatLng position,
    String title = 'Pickup Location',
    String? snippet,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      onTap: onTap,
    );
  }

  /// Create a dropoff marker (red)
  static Marker createDropoffMarker({
    required String markerId,
    required LatLng position,
    String title = 'Dropoff Location',
    String? snippet,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      onTap: onTap,
    );
  }

  /// Create a driver marker (blue)
  static Marker createDriverMarker({
    required String markerId,
    required LatLng position,
    String title = 'Driver',
    String? snippet,
    double rotation = 0.0,
    VoidCallback? onTap,
    BitmapDescriptor? customIcon,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: customIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      rotation: rotation,
      anchor: const Offset(0.5, 0.5),
      onTap: onTap,
    );
  }

  /// Create a hospital marker (cyan/azure)
  static Marker createHospitalMarker({
    required String markerId,
    required LatLng position,
    required String hospitalName,
    String? address,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: hospitalName,
        snippet: address,
      ),
      onTap: onTap,
    );
  }

  /// Create a custom colored marker
  static Marker createCustomMarker({
    required String markerId,
    required LatLng position,
    required double hue,
    String? title,
    String? snippet,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      onTap: onTap,
    );
  }
}

/// Helper class for creating polylines
class PolylineHelper {
  /// Create a route polyline
  static Polyline createRoutePolyline({
    required String polylineId,
    required List<LatLng> points,
    Color color = Colors.blue,
    int width = 5,
    bool geodesic = true,
    List<PatternItem>? patterns,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      geodesic: geodesic,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      patterns: patterns ?? [],
    );
  }

  /// Create a dashed polyline effect (for estimated route)
  static Polyline createDashedPolyline({
    required String polylineId,
    required List<LatLng> points,
    Color color = Colors.grey,
    int width = 3,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      geodesic: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  /// Create an animated route polyline
  static Polyline createAnimatedPolyline({
    required String polylineId,
    required List<LatLng> points,
    Color color = Colors.blue,
    int width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      geodesic: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
  }

  /// Create a dotted polyline
  static Polyline createDottedPolyline({
    required String polylineId,
    required List<LatLng> points,
    Color color = Colors.grey,
    int width = 3,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      geodesic: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }
}

/// Helper class for creating circles (radius indicators)
class CircleHelper {
  /// Create a radius circle around a point
  static Circle createRadiusCircle({
    required String circleId,
    required LatLng center,
    double radiusMeters = 5000,
    Color fillColor = Colors.blue,
    Color strokeColor = Colors.blue,
    int strokeWidth = 2,
    double fillOpacity = 0.2,
  }) {
    return Circle(
      circleId: CircleId(circleId),
      center: center,
      radius: radiusMeters,
      fillColor: fillColor.withOpacity(fillOpacity),
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      visible: true,
    );
  }

  /// Create a search radius circle
  static Circle createSearchRadiusCircle({
    required String circleId,
    required LatLng center,
    double radiusKm = 5.0,
  }) {
    return Circle(
      circleId: CircleId(circleId),
      center: center,
      radius: radiusKm * 1000, // Convert km to meters
      fillColor: Colors.blue.withOpacity(0.15),
      strokeColor: Colors.blue.withOpacity(0.5),
      strokeWidth: 2,
      visible: true,
    );
  }

  /// Create a danger/alert radius circle
  static Circle createAlertCircle({
    required String circleId,
    required LatLng center,
    double radiusMeters = 1000,
  }) {
    return Circle(
      circleId: CircleId(circleId),
      center: center,
      radius: radiusMeters,
      fillColor: Colors.red.withOpacity(0.2),
      strokeColor: Colors.red.withOpacity(0.7),
      strokeWidth: 2,
      visible: true,
    );
  }
}

/// Map controller wrapper for easier usage
class MapControllerWrapper {
  final GoogleMapController controller;

  MapControllerWrapper(this.controller);

  /// Animate to location
  Future<void> animateToLocation(LatLng location, {double zoom = 15.0}) {
    return controller.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoom),
    );
  }

  /// Fit bounds to show all points
  Future<void> fitBounds(LatLngBounds bounds, {double padding = 50}) {
    return controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  /// Zoom in
  Future<void> zoomIn() {
    return controller.animateCamera(CameraUpdate.zoomIn());
  }

  /// Zoom out
  Future<void> zoomOut() {
    return controller.animateCamera(CameraUpdate.zoomOut());
  }

  /// Get visible region
  Future<LatLngBounds> getVisibleRegion() {
    return controller.getVisibleRegion();
  }

  /// Take snapshot
  Future<Uint8List?> takeSnapshot() {
    return controller.takeSnapshot();
  }

  /// Set map style (for dark mode, custom styling)
  Future<void> setMapStyle(String? mapStyle) {
    return controller.setMapStyle(mapStyle);
  }

  /// Move camera to new position
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return controller.animateCamera(cameraUpdate);
  }
}

/// Extension for easier LatLngBounds creation
extension LatLngBoundsExtension on List<LatLng> {
  /// Create bounds from list of coordinates
  LatLngBounds toBounds() {
    if (isEmpty) {
      throw Exception('Cannot create bounds from empty list');
    }

    double minLat = first.latitude;
    double maxLat = first.latitude;
    double minLng = first.longitude;
    double maxLng = first.longitude;

    for (var point in this) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

/// Predefined marker colors
class MarkerColors {
  static const double red = BitmapDescriptor.hueRed;
  static const double green = BitmapDescriptor.hueGreen;
  static const double blue = BitmapDescriptor.hueBlue;
  static const double azure = BitmapDescriptor.hueAzure;
  static const double cyan = BitmapDescriptor.hueCyan;
  static const double magenta = BitmapDescriptor.hueMagenta;
  static const double orange = BitmapDescriptor.hueOrange;
  static const double rose = BitmapDescriptor.hueRose;
  static const double violet = BitmapDescriptor.hueViolet;
  static const double yellow = BitmapDescriptor.hueYellow;
}
