import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/address.dart';

void main() {
  group('Address Model Tests', () {
    test('fromMap should create an Address object correctly', () {
      final map = {
        'id': '123',
        'street': 'Uly Dala 31',
        'apartment': '510',
        'city': 'Astana',
        'country': 'Kazakhstan',
        'isDefault': true,
      };

      final address = Address.fromMap(map);

      expect(address.id, '123');
      expect(address.street, 'Uly Dala 31');
      expect(address.apartment, '510');
      expect(address.city, 'Astana');
      expect(address.country, 'Kazakhstan');
      expect(address.isDefault, true);
    });

    test('toMap should return a correct map', () {
      final address = Address(
        id: '123',
        street: 'Uly Dala 31',
        apartment: '510',
        city: 'Astana',
        country: 'Kazakhstan',
        isDefault: true,
      );

      final map = address.toMap();

      expect(map['id'], '123');
      expect(map['street'], 'Uly Dala 31');
      expect(map['apartment'], '510');
      expect(map['city'], 'Astana');
      expect(map['country'], 'Kazakhstan');
      expect(map['isDefault'], true);
    });

    test('formatted should return a joined string', () {
      final address = Address(
        id: '123',
        street: 'Uly Dala 31',
        apartment: '510',
        city: 'Astana',
        country: 'Kazakhstan',
      );

      expect(address.formatted, 'Uly Dala 31, 510, Astana, Kazakhstan');
    });

    test('copyWith should update fields correctly', () {
      final address = Address(
        id: '1',
        street: 'S1',
        city: 'C1',
      );

      final updated = address.copyWith(street: 'S2', isDefault: true);

      expect(updated.id, '1');
      expect(updated.street, 'S2');
      expect(updated.city, 'C1');
      expect(updated.isDefault, true);
    });
  });
}
