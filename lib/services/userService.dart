import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/cartItem.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  // ✅ Получить ID текущего пользователя
  String? get currentUserId => _auth.currentUser?.uid;

  // ✅ Получить текущего пользователя
  Future<User?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }

  // ✅ Создать нового пользователя (после регистрации)
  Future<void> createUser({
    required String email,
    String? name,
    String? phone,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final user = User(
      id: userId,
      email: email,
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(userId).set(user.toFirestore());
  }

  // ✅ Обновить профиль пользователя
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _firestore.collection(_collection).doc(userId).update(updates);
  }

  Future<List<String>> getFavorites() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return List<String>.from(data?['favorites'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Error fetching favorites: $e');
      return [];
    }
  }

  // ✅ Добавить в избранное
  Future<void> addToFavorites(String productId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(_collection).doc(userId).update({
      'favorites': FieldValue.arrayUnion([productId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Удалить из избранного
  Future<void> removeFromFavorites(String productId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(_collection).doc(userId).update({
      'favorites': FieldValue.arrayRemove([productId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Проверить, в избранном ли товар
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  // ✅ Добавить товар в корзину
  Future<void> addToCart(CartItem item) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final user = await getCurrentUser();
    final existingItem = user?.cart.firstWhere(
          (cartItem) => cartItem.productId == item.productId,
      orElse: () => CartItem(
        productId: '',
        name: '',
        price: 0,
        quantity: 0,
      ),
    );

    if (existingItem!.productId.isNotEmpty) {
      // Товар уже есть — увеличиваем количество
      await _updateCartItemQuantity(item.productId, existingItem.quantity + item.quantity);
    } else {
      // Новый товар — добавляем
      await _firestore.collection(_collection).doc(userId).update({
        'cart': FieldValue.arrayUnion([item.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ Обновить количество товара в корзине
  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    await _updateCartItemQuantity(productId, quantity);
  }

  Future<void> _updateCartItemQuantity(String productId, int quantity) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final user = await getCurrentUser();
    final updatedCart = user?.cart.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    await _firestore.collection(_collection).doc(userId).update({
      'cart': updatedCart?.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Удалить товар из корзины
  Future<void> removeFromCart(String productId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final user = await getCurrentUser();
    final updatedCart = user?.cart.where((item) => item.productId != productId).toList();

    await _firestore.collection(_collection).doc(userId).update({
      'cart': updatedCart?.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Очистить корзину
  Future<void> clearCart() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(_collection).doc(userId).update({
      'cart': [],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Добавить заказ пользователю
  Future<void> addOrder(String orderId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(_collection).doc(userId).update({
      'orders': FieldValue.arrayUnion([orderId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Удалить аккаунт
  Future<void> deleteAccount() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Удалить документ пользователя
    await _firestore.collection(_collection).doc(userId).delete();

    // Удалить аккаунт в Auth
    await _auth.currentUser?.delete();
  }
}