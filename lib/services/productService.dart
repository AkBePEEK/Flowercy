import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore;
  final String _collection = 'products';

  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ✅ Получить все товары
  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error fetching products: $e');
      return [];
    }
  }

  // ✅ Получить товары по категории
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error fetching products by category: $e');
      return [];
    }
  }

  // ✅ НОВЫЙ МЕТОД: Получить товары конкретного магазина
  Future<List<Product>> getProductsByShop(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error fetching products by shop: $e');
      return [];
    }
  }

  // ✅ Получить товар по ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching product: $e');
      return null;
    }
  }

  // ✅ Поиск товаров
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Загружаем все товары и фильтруем на клиенте
      final snapshot = await _firestore.collection(_collection).get();
      final allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      final lowerQuery = query.toLowerCase();

      return allProducts.where((product) =>
      product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery)
      ).toList();
    } catch (e) {
      print('❌ Error searching products: $e');
      return [];
    }
  }

  // ✅ НОВЫЙ МЕТОД: Создать товар
  Future<String?> createProduct(Product product) async {
    try {
      final docRef = await _firestore.collection(_collection).add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('❌ Error creating product: $e');
      return null;
    }
  }

  // ✅ НОВЫЙ МЕТОД: Обновить товар
  Future<bool> updateProduct(Product product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update(product.toFirestore());
      return true;
    } catch (e) {
      print('❌ Error updating product: $e');
      return false;
    }
  }

  // ✅ НОВЫЙ МЕТОД: Удалить товар
  Future<bool> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('❌ Error deleting product: $e');
      return false;
    }
  }

  // ✅ НОВЫЙ МЕТОД: Стрим всех товаров (для админки)
  Stream<List<Product>> getAllProductsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }
}