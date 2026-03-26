import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'orders';

  // ✅ Создать заказ
  Future<String> createOrder(Order order) async {
    final docRef = await _firestore.collection(_collection).add(order.toFirestore());
    return docRef.id;
  }

  // ✅ Получить заказы текущего пользователя
  Future<List<Order>> getUserOrders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Order.fromFirestore(doc as DocumentSnapshot<Object?>)).toList();
  }

  // ✅ Получить заказ по ID
  Future<Order?> getOrderById(String orderId) async {
    final doc = await _firestore.collection(_collection).doc(orderId).get();
    if (doc.exists) {
      return Order.fromFirestore(doc as DocumentSnapshot<Object?>);
    }
    return null;
  }

  // ✅ Обновить статус заказа
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(_collection).doc(orderId).update({'status': status});
  }
}