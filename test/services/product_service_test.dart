import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/productService.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProductService productService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    productService = ProductService(firestore: firestore);
  });

  group('ProductService Tests', () {
    test('getAllProducts returns all products', () async {
      await firestore.collection('products').add({
        'name': 'Rose Bouquet',
        'description': 'A beautiful bouquet of red roses',
        'price': 25000,
        'category': 'Bouquets',
        'imageUrl': 'rose.png',
        'shopId': 'shop1',
        'rating': 4.5,
        'reviewsCount': 10,
      });

      final products = await productService.getAllProducts();
      expect(products.length, 1);
      expect(products.first.name, 'Rose Bouquet');
    });

    test('getProductsByCategory returns filtered products', () async {
      await firestore.collection('products').add({
        'name': 'Rose',
        'category': 'Bouquets',
        'price': 1000,
        'description': 'desc',
        'imageUrl': 'img',
        'shopId': 'shop1',
      });
      await firestore.collection('products').add({
        'name': 'Tulip',
        'category': 'Flowers',
        'price': 800,
        'description': 'desc',
        'imageUrl': 'img',
        'shopId': 'shop1',
      });

      final bouquets = await productService.getProductsByCategory('Bouquets');
      expect(bouquets.length, 1);
      expect(bouquets.first.name, 'Rose');
    });

    test('getProductsByShop returns shop products', () async {
      await firestore.collection('products').add({
        'name': 'Shop 1 Product',
        'shopId': 'shop1',
        'price': 1000,
        'description': 'desc',
        'imageUrl': 'img',
        'category': 'cat',
      });
      await firestore.collection('products').add({
        'name': 'Shop 2 Product',
        'shopId': 'shop2',
        'price': 1000,
        'description': 'desc',
        'imageUrl': 'img',
        'category': 'cat',
      });

      final shop1Products = await productService.getProductsByShop('shop1');
      expect(shop1Products.length, 1);
      expect(shop1Products.first.name, 'Shop 1 Product');
    });

    test('getProductById returns correct product', () async {
      final docRef = await firestore.collection('products').add({
        'name': 'Target Product',
        'price': 1000,
        'description': 'desc',
        'imageUrl': 'img',
        'category': 'cat',
        'shopId': 'shop1',
      });

      final product = await productService.getProductById(docRef.id);
      expect(product, isNotNull);
      expect(product!.name, 'Target Product');
    });

    test('searchProducts returns matching products', () async {
      await firestore.collection('products').add({
        'name': 'Red Rose',
        'description': 'Beautiful',
        'category': 'Bouquets',
        'price': 1000,
        'imageUrl': 'img',
        'shopId': 'shop1',
      });
      await firestore.collection('products').add({
        'name': 'White Lily',
        'description': 'Elegant',
        'category': 'Flowers',
        'price': 1200,
        'imageUrl': 'img',
        'shopId': 'shop1',
      });

      final results = await productService.searchProducts('rose');
      expect(results.length, 1);
      expect(results.first.name, 'Red Rose');
    });
  });
}
