import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/shopService.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ShopService shopService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    shopService = ShopService(firestore: firestore);
  });

  group('ShopService Tests', () {
    test('getAllShops returns all shops', () async {
      await firestore.collection('shops').add({
        'name': 'Flower Shop 1',
        'address': 'Address 1',
        'imageUrl': 'img1',
        'rating': 4.8,
        'reviewsCount': 50,
      });

      final shops = await shopService.getAllShops();
      expect(shops.length, 1);
      expect(shops.first.name, 'Flower Shop 1');
    });

    test('getShopById returns correct shop', () async {
      final docRef = await firestore.collection('shops').add({
        'name': 'Target Shop',
        'address': 'Target Address',
        'imageUrl': 'img',
        'rating': 5.0,
        'reviewsCount': 100,
      });

      final shop = await shopService.getShopById(docRef.id);
      expect(shop, isNotNull);
      expect(shop!.name, 'Target Shop');
    });
  });
}
