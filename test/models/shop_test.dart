import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/shop.dart';

void main() {
  group('Shop Model Tests', () {
    test('fromFirestore should create a Shop object correctly', () async {
      final firestore = FakeFirebaseFirestore();
      final data = {
        'name': 'Flower Shop',
        'rating': 4.8,
        'reviews': 100,
        'image': 'shop.png',
        'address': 'Main St',
        'phone': '123456',
        'isOpen': true,
      };

      await firestore.collection('shops').doc('s123').set(data);
      final snapshot = await firestore.collection('shops').doc('s123').get();

      final shop = Shop.fromFirestore(snapshot);

      expect(shop.id, 's123');
      expect(shop.name, 'Flower Shop');
      expect(shop.rating, 4.8);
      expect(shop.isOpen, true);
    });

    test('toFirestore should return a correct map', () {
      final shop = Shop(
        id: 's123',
        name: 'Shop',
        rating: 4.5,
        reviews: 20,
        image: 'img',
        address: 'Addr',
        phone: '111',
      );

      final map = shop.toFirestore();

      expect(map['name'], 'Shop');
      expect(map['rating'], 4.5);
      expect(map['address'], 'Addr');
    });
  });
}
