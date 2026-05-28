import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/seed_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SeedService seedService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    seedService = SeedService(firestore: firestore);
  });

  group('SeedService Tests', () {
    test('seedAll populates shops and products', () async {
      await seedService.seedAll();

      final shopsSnapshot = await firestore.collection('shops').get();
      final productsSnapshot = await firestore.collection('products').get();

      expect(shopsSnapshot.docs.isNotEmpty, true);
      expect(productsSnapshot.docs.isNotEmpty, true);
      
      // Verify some specific data
      final firstShop = shopsSnapshot.docs.first.data();
      expect(firstShop['name'], isNotNull);
      
      final firstProduct = productsSnapshot.docs.first.data();
      expect(firstProduct['shopId'], isNotNull);
    });

    test('clears existing data before seeding', () async {
      // Pre-populate with some data
      await firestore.collection('shops').add({'name': 'Old Shop'});
      
      await seedService.seedAll();

      final shopsSnapshot = await firestore.collection('shops').get();
      final shopNames = shopsSnapshot.docs.map((d) => d.data()['name']).toList();
      
      expect(shopNames.contains('Old Shop'), false);
      expect(shopNames.length, greaterThan(0));
    });
  });
}
