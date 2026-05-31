import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../models/order.dart' as local;
import '../models/bouquetRequest.dart';
import 'api/api_client.dart';
import '../models/api/api_order.dart';

class OrderService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ApiClient _apiClient;

  OrderService({FirebaseFirestore? firestore, FirebaseAuth? auth, ApiClient? apiClient})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _apiClient = apiClient ?? ApiClient(Dio());

  final String _collection = 'orders';
  final String _requestCollection = 'bouquet_requests';

  // ✅ Создать заказ (теперь через API)
  Future<ApiOrder> createOrderAtBackend(Map<String, dynamic> orderData) async {
    try {
      return await _apiClient.createOrder(orderData);
    } catch (e) {
      print('❌ Error creating order at backend: $e');
      rethrow;
    }
  }

  // Legacy Firestore support
  Future<String> createOrder(local.Order order) async {
    final docRef = await _firestore.collection(_collection).add(order.toFirestore());
    return docRef.id;
  }

  // ✅ Создать запрос на букет (AI)
  Future<String> createBouquetRequest(BouquetRequest request) async {
    final docRef = await _firestore.collection(_requestCollection).add(request.toFirestore());
    return docRef.id;
  }

  Stream<List<local.Order>> getUserOrdersStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => local.Order.fromFirestore(doc))
        .toList());
  }

  // ✅ Получить заказ по ID из бэкенда
  Future<ApiOrder> getOrderFromBackend(String orderId) async {
    return await _apiClient.getOrder(orderId);
  }

  // ✅ Подтверждение заказа клиентом (фото флориста)
  Future<ApiOrder> reviewOrder(String orderId, bool approved, {String? note}) async {
    return await _apiClient.reviewOrder(orderId, {
      'decision': approved ? 'approve' : 'reject',
      if (note != null) 'note': note,
    });
  }

  // ✅ Оплата заказа
  Future<ApiOrder> markPaid(String orderId) async {
    return await _apiClient.markOrderAsPaid(orderId);
  }

  // ✅ Получить заказы текущего пользователя
  Future<List<local.Order>> getUserOrders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => local.Order.fromFirestore(doc)).toList();
  }

  // ✅ Получить заказ по ID
  Future<local.Order?> getOrderById(String orderId) async {
    final doc = await _firestore.collection(_collection).doc(orderId).get();
    if (doc.exists) {
      return local.Order.fromFirestore(doc);
    }
    return null;
  }

  // ✅ Получить стрим заказа по ID (для отслеживания статуса в реальном времени)
  Stream<local.Order?> getOrderStream(String orderId) {
    return _firestore
        .collection(_collection)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? local.Order.fromFirestore(doc) : null);
  }

  // ✅ Обновить статус заказа
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(_collection).doc(orderId).update({'status': status});
  }

  // ✅ Обновить статус запроса на букет
  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection(_requestCollection).doc(requestId).update({'status': status});
  }

  // ✅ Получить все заказы (для админа)
  Stream<List<local.Order>> getAllOrdersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => local.Order.fromFirestore(doc)).toList();
    });
  }

  // ✅ Получить все запросы на букеты (для админа)
  Stream<List<BouquetRequest>> getAllBouquetRequestsStream() {
    return _firestore
        .collection(_requestCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BouquetRequest.fromFirestore(doc)).toList();
    });
  }
}
