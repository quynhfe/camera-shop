class StoreLocation {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String hours;

  StoreLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.hours,
  });

  factory StoreLocation.fromMap(Map<String, dynamic> map) {
    return StoreLocation(
      id: map['id'] as int,
      name: (map['name'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      phone: (map['phone'] as String?) ?? '',
      hours: (map['hours'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'hours': hours,
    };
  }
}
