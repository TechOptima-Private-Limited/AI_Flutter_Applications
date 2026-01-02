enum TransportMode {
  bike,
  auto,
  sedan,
  suv,
  premium,
}

extension TransportModeExtension on TransportMode {
  String get name {
    switch (this) {
      case TransportMode.bike:
        return 'Bike';
      case TransportMode.auto:
        return 'Auto';
      case TransportMode.sedan:
        return 'Sedan';
      case TransportMode.suv:
        return 'SUV';
      case TransportMode.premium:
        return 'Premium';
    }
  }

  String get icon {
    switch (this) {
      case TransportMode.bike:
        return '🏍️';
      case TransportMode.auto:
        return '🛺';
      case TransportMode.sedan:
        return '🚗';
      case TransportMode.suv:
        return '🚙';
      case TransportMode.premium:
        return '🚘';
    }
  }

  double get basePrice {
    switch (this) {
      case TransportMode.bike:
        return 50;
      case TransportMode.auto:
        return 80;
      case TransportMode.sedan:
        return 150;
      case TransportMode.suv:
        return 200;
      case TransportMode.premium:
        return 300;
    }
  }

  double get pricePerKm {
    switch (this) {
      case TransportMode.bike:
        return 8;
      case TransportMode.auto:
        return 12;
      case TransportMode.sedan:
        return 18;
      case TransportMode.suv:
        return 25;
      case TransportMode.premium:
        return 35;
    }
  }

  int get capacity {
    switch (this) {
      case TransportMode.bike:
        return 1;
      case TransportMode.auto:
        return 3;
      case TransportMode.sedan:
        return 4;
      case TransportMode.suv:
        return 6;
      case TransportMode.premium:
        return 4;
    }
  }
}
