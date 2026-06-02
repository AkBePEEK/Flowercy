import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/product.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Product Model Tests', () {
    test('fromFirestore should create a Product object correctly', () async {
      final firestore = FakeFirebaseFirestore();
      final data = {
        'name': 'Rose',
        'price': 1500,
        'currency': '₸',
        'description': 'Beautiful rose',
        'images': ['img1.png'],
        'shopId': 'shop1',
        'category': 'flowers',
        'section': 'bouquets',
        'rating': 4.5,
        'reviews': 10,
        'freeDelivery': true,
        'inStock': true,
      };

      await firestore.collection('products').doc('p123').set(data);
      final snapshot = await firestore.collection('products').doc('p123').get();

      final product = Product.fromFirestore(snapshot);

      expect(product.id, 'p123');
      expect(product.name, 'Rose');
      expect(product.price, 1500);
      expect(product.section, 'bouquets');
      expect(product.rating, 4.5);
      expect(product.freeDelivery, true);
    });

    test('toFirestore should return a correct map', () {
      final product = Product(
        id: 'p123',
        name: 'Rose',
        price: 1500,
        description: 'Desc',
        images: [],
        shopId: 's1',
        category: 'cat',
        section: 'sec',
        rating: 4.0,
        reviews: 5,
      );

      final map = product.toFirestore();

      expect(map['name'], 'Rose');
      expect(map['price'], 1500);
      expect(map['section'], 'sec');
      expect(map['rating'], 4.0);
    });

    test('formattedPrice should return a correct string', () {
      final product = Product(
        id: 'p1', name: 'N', price: 1000, currency: '\$', description: '', images: [], shopId: '', category: '', section: '', rating: 0, reviews: 0
      );
      expect(product.formattedPrice, '1000 \$');
    });
  });
}
