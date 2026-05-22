class Address {
  final String id;
  final String street;
  final String? apartment; // квартира/офис/этаж
  final String city;
  final String? country;
  final bool isDefault;

  Address({
    required this.id,
    required this.street,
    this.apartment,
    required this.city,
    this.country = 'Kazakhstan',
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      street: data['street'] ?? '',
      apartment: data['apartment'],
      city: data['city'] ?? '',
      country: data['country'] ?? 'Kazakhstan',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'street': street,
      'apartment': apartment,
      'city': city,
      'country': country,
      'isDefault': isDefault,
    };
  }

  // ✅ Форматированный адрес для отображения
  String get formatted {
    final parts = [street];
    if (apartment?.isNotEmpty == true) parts.add(apartment!);
    parts.add(city);
    if (country?.isNotEmpty == true) parts.add(country!);
    return parts.join(', ');
  }

  // ✅ Копия с изменениями
  Address copyWith({
    String? id,
    String? street,
    String? apartment,
    String? city,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}