import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // ✅ Получить все товары
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  // ✅ Получить товары по категории
  Future<List<Product>> getProductsByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  // ✅ Поиск товаров по названию
  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final allProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      // Фильтрация на клиенте
      return allProducts.where((product) {
        final name = product.name.toLowerCase();
        final desc = product.description.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || desc.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('❌ Error searching products: $e');
      return [];
    }
  }

  // ✅ Получить товар по ID
  Future<Product?> getProductById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }
}