// lib/src/models/vehicle_type.dart

enum VehicleType {
  bike,
  auto,
  sedan,
  suv,
  luxury;

  String get displayName {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.auto:
        return 'Auto Rickshaw';
      case VehicleType.sedan:
        return 'Sedan';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.luxury:
        return 'Luxury';
    }
  }

  String get description {
    switch (this) {
      case VehicleType.bike:
        return 'Quick and affordable';
      case VehicleType.auto:
        return 'Compact and economical';
      case VehicleType.sedan:
        return 'Comfortable rides';
      case VehicleType.suv:
        return 'Spacious for groups';
      case VehicleType.luxury:
        return 'Premium experience';
    }
  }

  double get baseFare {
    switch (this) {
      case VehicleType.bike:
        return 30.0;
      case VehicleType.auto:
        return 40.0;
      case VehicleType.sedan:
        return 50.0;
      case VehicleType.suv:
        return 70.0;
      case VehicleType.luxury:
        return 100.0;
    }
  }

  double get perKmRate {
    switch (this) {
      case VehicleType.bike:
        return 8.0;
      case VehicleType.auto:
        return 10.0;
      case VehicleType.sedan:
        return 15.0;
      case VehicleType.suv:
        return 20.0;
      case VehicleType.luxury:
        return 30.0;
    }
  }

  int get capacity {
    switch (this) {
      case VehicleType.bike:
        return 1;
      case VehicleType.auto:
        return 3;
      case VehicleType.sedan:
        return 4;
      case VehicleType.suv:
        return 6;
      case VehicleType.luxury:
        return 4;
    }
  }
}
